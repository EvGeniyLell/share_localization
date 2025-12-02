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
      pSettings.languages.forEach((language) async {
        final locale = generateLocale(pSettings, language, localization);
        await fileService.createFile(
          path: filePath(pSettings, language, localization),
          content: locale,
        );
      });
    });
  }

  String filePath(
    FlutterSettingsDto settings,
    SettingsLanguageDto? language,
    LocalizationDto localization,
  ) {
    return '${settings.options.destinationFolder}'
        '/${localization.name.baseFilename()}'
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
  String flutterEscape() {
    return replaceAll("'", r"\'").replaceAll('\n', r'\n').replaceAllMapped(
      RegExp(r'{(\w+)}'),
      (math) {
        return '\$${math.group(1)}';
      },
    );
  }

  String flutterDescriptionEscape() {
    return replaceAll('\n', r'\n');
  }
}
