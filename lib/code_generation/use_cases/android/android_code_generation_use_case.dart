import 'package:meta/meta.dart';
import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/use_cases/code_generation_use_case.dart';
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
      await Future.wait(pSettings.languages.map((language) async {
        final xml = generateXml(pSettings, language, localization);
        await fileService.createFile(
          path: filePath(pSettings, language, localization, xmlExtension),
          content: xml,
        );
      }));
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
  String androidTranslationEscape() {
    // Backslash must come first, or the `\` added by the later replacements
    // would be doubled too.
    final escaped = replaceAll(RegExp(r'\\'), r'\\')
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll("'", r"\'")
        .replaceAll('\n', r'\n');
    if (escaped.startsWith('@') || escaped.startsWith('?')) {
      return '\\$escaped';
    }
    return escaped;
  }

  String androidDescriptionEscape() {
    return replaceAll('\n', r'\n');
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
