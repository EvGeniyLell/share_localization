import 'package:meta/meta.dart';
import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/use_cases/code_generation_use_case.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';
import 'package:share_localization/settings/settings.dart' as settings;

part 'android_code_generation_use_case_xml.dart';

class AndroidCodeGenerationUseCase extends CodeGenerationUseCase {
  static const xmlExtension = 'xml';

  const AndroidCodeGenerationUseCase(super.fileService);

  @override
  Task<void> call(settings.SettingsDto settings, LocalizationDto localization) {
    return runAppTaskSafely(() async {
      final options = settings.android;
      if (options == null) {
        throw const BuildLocalizationException.missingIosSettings();
      }
      settings.languages.forEach((language) async {
        final xml = generateXml(settings, language, localization);
        await fileService.createFile(
          path: filePath(options, language, localization, xmlExtension),
          content: xml,
        );
      });
    });
  }

  String filePath(
    settings.AndroidOptionsDto options,
    settings.LanguageDto? language,
    LocalizationDto localization,
    String extension,
  ) {
    final useCamelCase = options.useCamelCase ?? false;
    final fileName = localization.name.baseFilename().nullSafe((name) {
      return useCamelCase ? name.camelCase() : name;
    });
    final languageKey = language != null ? '_${language.key}' : '';
    return '${options.destinationFolder}/$fileName$languageKey.$extension';
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
    return replaceAll('<', '&lt;');
  }

  String androidArgumentsEscape(List<LocalizationKeyArgumentDto> arguments) {
    int index = 0;
    return replaceAllMapped(RegExp(r'{(\w+)}'), (math) {
      final argument = arguments.elementAtOrNull(index++)?.type ??
          LocalizationKeyDtoType.string;
      return '%$index${argument.androidType}';
    });
  }
}
