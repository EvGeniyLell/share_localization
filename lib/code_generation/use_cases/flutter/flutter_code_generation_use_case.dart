import 'package:meta/meta.dart';
import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/use_cases/code_generation_use_case.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';
import 'package:share_localization/settings/settings.dart' as settings;

part 'flutter_code_generation_use_case_common.dart';
part 'flutter_code_generation_use_case_locale.dart';

class FlutterCodeGenerationUseCase extends CodeGenerationUseCase {
  const FlutterCodeGenerationUseCase(super.fileService);

  @override
  Task<void> call(settings.SettingsDto settings, LocalizationDto localization) {
    return runAppTaskSafely(() async {
      final options = settings.flutter;
      if (options == null) {
        throw const BuildLocalizationException.missingFlutterSettings();
      }
      final common = generateCommon(settings, localization);
      await fileService.createFile(
        path: filePath(options, null, localization),
        content: common,
      );
      settings.languages.forEach((language) async {
        final locale = generateLocale(settings, language, localization);
        await fileService.createFile(
          path: filePath(options, language, localization),
          content: locale,
        );
      });
    });
  }

  String filePath(
    settings.FlutterOptionsDto options,
    settings.LanguageDto? language,
    LocalizationDto localization,
  ) {
    return '${options.destinationFolder}'
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
    return replaceAll("'", r"\'").replaceAllMapped(RegExp(r'{(\w+)}'), (math) {
      return '\$${math.group(1)}';
    });
  }
}
