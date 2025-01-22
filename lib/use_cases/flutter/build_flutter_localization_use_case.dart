import 'package:meta/meta.dart';
import 'package:share_localization/exceptions/exceptions.dart';
import 'package:share_localization/use_cases/build_localization_use_case.dart';
import 'package:share_localization/utils/string_case_transform_extension.dart';

part 'build_flutter_localization_use_case_common.dart';
part 'build_flutter_localization_use_case_locale.dart';

class BuildFlutterLocalizationUseCase extends BuildLocalizationUseCase {
  const BuildFlutterLocalizationUseCase();

  @override
  AppTask<void> call(SettingsDto settings, LocalizationDto localization) {
    return runAppTaskSafely(() async {
      final flutter = settings.flutter;
      if (flutter == null) {
        throw const BuildLocalizationException.missingFlutterSettings();
      }
      final common = buildCommon(settings, localization);
      await createFile(filePath(flutter, localization), common);
      settings.languages.forEach((language) async {
        final locale = buildLocale(settings, localization, language);
        await createFile(filePath(flutter, localization, language), locale);
      });
    });
  }

  String filePath(
    FlutterSettingsDto settings,
    LocalizationDto localization, [
    LanguageDto? language,
  ]) {
    return '${settings.destinationFolder}'
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
