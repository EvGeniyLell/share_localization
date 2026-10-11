import 'package:meta/meta.dart';
import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/exceptions/duplicate_resource_name_exception.dart';
import 'package:share_localization/code_generation/use_cases/code_generation_use_case.dart';
import 'package:share_localization/code_generation/use_cases/resource_name_validation.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';
import 'package:share_localization/settings/settings.dart';

part 'flutter_code_generation_use_case_common.dart';
part 'flutter_code_generation_use_case_locale.dart';

class FlutterCodeGenerationUseCase extends CodeGenerationUseCase {
  const FlutterCodeGenerationUseCase(super.fileService);

  @override
  Task<void> call(SettingsDto settings, LocalizationDto localization) {
    return runAppTaskSafely(() async {
      final FlutterSettingsDto? pSettings = settings.toPlatformSettingsDto();
      if (pSettings == null) {
        throw const BuildLocalizationException.missingFlutterSettings();
      }
      _validateResourceNames(localization);
      final common = generateCommon(pSettings, localization);
      await fileService.createFile(
        path: filePath(pSettings, null, localization),
        content: common,
      );
      await Future.wait(pSettings.languages.map((language) async {
        final locale = generateLocale(pSettings, language, localization);
        await fileService.createFile(
          path: filePath(pSettings, language, localization),
          content: locale,
        );
      }));
    });
  }

  /// Throws before any file is written if a key gives an invalid or duplicate
  /// name, see [validateResourceNames].
  void _validateResourceNames(LocalizationDto localization) {
    validateResourceNames(
      platform: ResourcePlatform.flutter,
      bundleName: localization.name,
      entries: localization.keys.map((key) {
        final name = _flutterItemName(key);
        return ResourceNameEntry(key: key.key, name: name, baseName: name);
      }),
    );
  }

  String filePath(
    FlutterSettingsDto settings,
    SettingsLanguageDto? language,
    LocalizationDto localization,
  ) {
    return '${settings.options.destinationFolder}'
        '/${localization.name.baseFilename().snakeCase()}'
        '_${localizationPostfix.snakeCase()}'
        '${language != null ? '_${language.key}' : ''}'
        '.dart';
  }
}

/// The Dart getter or method name of [key], used in the abstract class and in
/// every locale class, and checked by [validateResourceNames].
String _flutterItemName(LocalizationKeyDto key) => key.key.camelCase();

extension LocalizationKeyDtoTypeToFlutter on LocalizationKeyDtoType {
  String get dartType => switch (this) {
    LocalizationKeyDtoType.string => 'String',
    LocalizationKeyDtoType.int => 'int',
    LocalizationKeyDtoType.double => 'double',
  };
}

extension StringToFlutter on String {
  /// Escapes the text and turns `{argument_name}` into `$argumentName`.
  ///
  /// The name goes through the same `camelCase()` as the generated parameter,
  /// otherwise the body would refer to a name that does not exist. When the
  /// placeholder is followed by a character that can continue an identifier
  /// (`{size}MB`), the braces form `${size}MB` is used so Dart does not read
  /// `$sizeMB` as one name.
  ///
  /// A literal `\` is written as `\\` first, otherwise Dart reads sequences such
  /// as `\d` as invalid escapes, or `\n` as a newline. It is escaped before the
  /// other replacements, so the backslashes added for them are not doubled.
  ///
  /// A literal `$` is written as `\$`, otherwise it would start an
  /// interpolation. It is escaped before the placeholders are replaced, so the
  /// `$` added for them stays as is.
  String flutterEscape() {
    return replaceAll(RegExp(r'\\'), r'\\')
        .replaceAll("'", r"\'")
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll(r'$', r'\$')
        .replaceAllMapped(
      RegExp(r'{(\w+)}'),
      (match) {
        final name = match.group(1)!.camelCase();
        final next = match.end < match.input.length
            ? match.input[match.end]
            : '';
        // Dart identifiers are ASCII only.
        final continuesIdentifier = RegExp('[A-Za-z0-9_]').hasMatch(next);
        return continuesIdentifier ? '\${$name}' : '\$$name';
      },
    );
  }

  /// Escapes text written into a `///` doc comment line, such as the comment
  /// and the description. A real `\n` or `\r` would end the comment early, so
  /// each is written as the two characters `\n` or `\r`.
  String flutterDocCommentEscape() {
    return replaceAll('\n', r'\n').replaceAll('\r', r'\r');
  }
}
