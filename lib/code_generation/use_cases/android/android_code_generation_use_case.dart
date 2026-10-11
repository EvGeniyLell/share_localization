import 'package:meta/meta.dart';
import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/exceptions/duplicate_resource_name_exception.dart';
import 'package:share_localization/code_generation/use_cases/code_generation_use_case.dart';
import 'package:share_localization/code_generation/use_cases/resource_name_validation.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';
import 'package:share_localization/settings/settings.dart';

part 'android_code_generation_use_case_xml.dart';

class AndroidCodeGenerationUseCase extends CodeGenerationUseCase {
  static const xmlExtension = 'xml';

  const AndroidCodeGenerationUseCase(super.fileService);

  @override
  Task<void> call(SettingsDto settings, LocalizationDto localization) {
    return runAppTaskSafely(() async {
      final AndroidSettingsDto? pSettings = settings.toPlatformSettingsDto();
      if (pSettings == null) {
        throw const BuildLocalizationException.missingAndroidSettings();
      }
      _validateResourceNames(pSettings, localization);
      await Future.wait(
        pSettings.languages.map((language) async {
          final xml = generateXml(pSettings, language, localization);
          await fileService.createFile(
            path: filePath(pSettings, language, localization, xmlExtension),
            content: xml,
          );
        }),
      );
    });
  }

  String filePath(
    AndroidSettingsDto settings,
    SettingsLanguageDto? language,
    LocalizationDto localization,
    String extension,
  ) {
    final fileName = localization.name.baseFilename().snakeCase();
    final languageKey = language.nullSafe((l) {
      if (l != null &&
          l.key.isNotEmpty &&
          l.key != settings.languages.firstOrNull?.key) {
        return '-${l.key}';
      }
      return '';
    });
    return '${settings.options.destinationFolder}$languageKey/$fileName.$extension';
  }

  /// Throws before any file is written if a key gives an invalid resource
  /// name, see [validateResourceNames].
  void _validateResourceNames(
    AndroidSettingsDto settings,
    LocalizationDto localization,
  ) {
    validateResourceNames(
      platform: ResourcePlatform.android,
      bundleName: localization.name,
      entries: _resourceEntries(settings, localization),
    );
  }

  @override
  AppException? validateBundle(
    SettingsDto settings,
    LocalizationDto localization,
  ) {
    final AndroidSettingsDto? pSettings = settings.toPlatformSettingsDto();
    if (pSettings == null) {
      return null;
    }
    try {
      _validateResourceNames(pSettings, localization);
    } on AppException catch (error) {
      return error;
    }
    return null;
  }

  /// All bundles share one Android resource namespace, so a name taken by
  /// one bundle cannot be used by another. Bundles are checked in name
  /// order, so the first holder of a name is the same on every run. Same-
  /// bundle duplicates and invalid names are left to [call].
  @override
  List<AppException> validateBundles(
    SettingsDto settings,
    List<LocalizationDto> localizations,
  ) {
    final AndroidSettingsDto? pSettings = settings.toPlatformSettingsDto();
    if (pSettings == null) {
      return const [];
    }
    final sorted = [...localizations]..sort((a, b) => a.name.compareTo(b.name));
    // The first bundle and key that took each final name.
    final firstHolder = <String, (String bundleName, String key)>{};
    final errors = <AppException>[];
    for (final localization in sorted) {
      for (final entry in _resourceEntries(pSettings, localization)) {
        if (!isDuplicateCheckable(entry)) {
          continue;
        }
        final holder = firstHolder[entry.identity];
        if (holder == null) {
          firstHolder[entry.identity] = (localization.name, entry.key);
        } else if (holder.$1 != localization.name) {
          errors.add(
            DuplicateResourceNameException(
              platform: ResourcePlatform.android,
              key: entry.key,
              otherKey: holder.$2,
              name: entry.name,
              bundleName: localization.name,
              otherBundleName: holder.$1,
            ),
          );
        }
      }
    }
    return errors;
  }
}

/// One entry per key of [localization], with the final name and the name
/// without prefix. Used by both the per-bundle and the cross-bundle checks.
List<ResourceNameEntry> _resourceEntries(
  AndroidSettingsDto settings,
  LocalizationDto localization,
) {
  final keyPrefix = _localizationKeyPrefix(settings, localization);
  return [
    for (final key in localization.keys)
      ResourceNameEntry(
        key: key.key,
        name: _itemName(settings, keyPrefix, key.key),
        baseName: _itemName(settings, '', key.key),
      ),
  ];
}

/// The file name prefix added to keys, or empty when prefixes are off.
String _localizationKeyPrefix(
  AndroidSettingsDto settings,
  LocalizationDto localization,
) {
  return switch (settings.options.useFilePrefixForKeys) {
    true => localization.name.baseFilename(),
    false => '',
  };
}

/// The final Android resource name of [key], with [localizationKeyPrefix]
/// added in front when it is not empty.
String _itemName(
  AndroidSettingsDto settings,
  String localizationKeyPrefix,
  String key,
) {
  final fullKey = [
    localizationKeyPrefix,
    key,
  ].where((s) => s.isNotEmpty).join('_');
  return settings.options.useCamelCase
      ? fullKey.camelCase()
      : fullKey.snakeCase();
}

extension LocalizationKeyDtoTypeToAndroid on LocalizationKeyDtoType {
  String get androidType => switch (this) {
    LocalizationKeyDtoType.string => r'$s',
    LocalizationKeyDtoType.int => r'$d',
    LocalizationKeyDtoType.double => r'$f',
  };
}

extension StringToAndroid on String {
  /// Makes a translation valid XML text and safe as a string resource.
  ///
  /// `&` must be replaced before `<`, otherwise the `&` of the new `&lt;`
  /// would be escaped again. A leading `@` or `?` is prefixed with a backslash,
  /// because Android reads it as a resource or theme attribute reference.
  /// A `"` becomes `\"`, because an unescaped quote is dropped from the output.
  /// Android collapses whitespace in unquoted values, so a tab becomes `\t` and
  /// leading, trailing or repeated spaces become `\u0020`. This is the
  /// Android resource rule and was not verified on a device.
  String androidTranslationEscape() {
    // Backslash must come first, or the `\` added by the later replacements
    // would be doubled too.
    final escaped = replaceAll(RegExp(r'\\'), r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll("'", r"\'")
        .replaceAll('\n', r'\n')
        .replaceAll('\t', r'\t')
        .replaceAll(RegExp(r'^ | $|(?<= ) '), r'\u0020');
    if (escaped.startsWith('@') || escaped.startsWith('?')) {
      return '\\$escaped';
    }
    return escaped;
  }

  /// Makes a description safe inside an XML comment.
  ///
  /// A comment must not contain `--`, so each hyphen followed by another
  /// hyphen is followed by a space instead (`--` becomes `- -`).
  String androidDescriptionEscape() {
    return replaceAll('\n', r'\n').replaceAll(RegExp('-(?=-)'), '- ');
  }

  /// Replaces `{name}` with a positional format specifier, e.g. `%2$d`.
  ///
  /// The position and type come from the declared [arguments], looked up by
  /// name, so translations may reorder or repeat placeholders.
  ///
  /// A string with arguments is used as a format string, so a literal `%` is
  /// written as `%%`. Without arguments it is read as plain text, where `%%`
  /// would be shown twice, so it is left as is.
  String androidArgumentsEscape(List<LocalizationKeyArgumentDto> arguments) {
    final text = arguments.isEmpty ? this : replaceAll('%', '%%');
    return text.replaceAllMapped(RegExp(r'{(\w+)}'), (match) {
      final index = arguments.indexWhere((a) => a.name == match.group(1));
      if (index == -1) {
        return match.group(0)!;
      }
      return '%${index + 1}${arguments[index].type.androidType}';
    });
  }
}
