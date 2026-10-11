import 'package:meta/meta.dart';
import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/use_cases/code_generation_use_case.dart';
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
  /// otherwise the body would refer to a name that does not exist.
  String flutterEscape() {
    return replaceAll("'", r"\'").replaceAll('\n', r'\n').replaceAllMapped(
      RegExp(r'{(\w+)}'),
      (math) {
        return '\$${math.group(1)!.camelCase()}';
      },
    );
  }

  String flutterDescriptionEscape() {
    return replaceAll('\n', r'\n');
  }
}
