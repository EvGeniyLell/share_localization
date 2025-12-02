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
        throw const BuildLocalizationException.missingIosSettings();
      }
      pSettings.languages.forEach((language) async {
        final xml = generateXml(pSettings, language, localization);
        await fileService.createFile(
          path: filePath(pSettings, language, localization, xmlExtension),
          content: xml,
        );
      });
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
  String androidTranslationEscape() {
    return replaceAll(
      '<',
      '&lt;',
    ).replaceAll("'", r"\'").replaceAll('\n', r'\n');
  }

  String androidDescriptionEscape() {
    return replaceAll('\n', r'\n');
  }

  String androidArgumentsEscape(List<LocalizationKeyArgumentDto> arguments) {
    int index = 0;
    return replaceAllMapped(RegExp(r'{(\w+)}'), (math) {
      final argument =
          arguments.elementAtOrNull(index++)?.type ??
          LocalizationKeyDtoType.string;
      return '%$index${argument.androidType}';
    });
  }
}
