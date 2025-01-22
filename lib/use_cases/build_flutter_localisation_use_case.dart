import 'package:meta/meta.dart';
import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/exceptions/exceptions.dart';
import 'package:share_localisation/use_cases/build_localisation_use_case.dart';
import 'package:share_localisation/utils/common.dart';
import 'package:share_localisation/utils/string_case_transform_extension.dart';

part 'build_flutter_localisation_use_case_common.dart';
part 'build_flutter_localisation_use_case_locale.dart';

class BuildFlutterLocalisationUseCase extends BuildLocalisationUseCase {
  const BuildFlutterLocalisationUseCase();

  @override
  AppTask<void> call(SettingsDto settings, LocalisationDto localisation) {
    return runAppTaskSafely(() async {
      final flutter = settings.flutter;
      if (flutter == null) {
        throw const BuildLocalisationException.missingFlutterSettings();
      }
      final common = buildCommon(settings, localisation);
      await createFile(filePath(flutter, localisation), common);
      settings.languages.forEach((language) async {
        final locale = buildLocale(settings, localisation, language);
        await createFile(filePath(flutter, localisation, language), locale);
      });
    });
  }

  String filePath(
      FlutterSettingsDto settings,
    LocalisationDto localisation, [
    LanguageDto? language,
  ]) {
    return '${settings.destinationFolder}'
        '/${localisation.name.baseFilename()}'
        '${language != null ? '_${language.key}' : ''}'
        '.dart';
  }
}

extension LocalisationKeyDtoTypeToFlutter on LocalisationKeyDtoType {
  String get dartType => switch (this) {
        LocalisationKeyDtoType.string => 'String',
        LocalisationKeyDtoType.int => 'int',
        LocalisationKeyDtoType.double => 'double',
      };
}

extension StringToFlutter on String {
  String flutterEscape() {
    return replaceAll("'", r"\'").replaceAllMapped(RegExp(r'{(\w+)}'), (math) {
      return '\$${math.group(1)}';
    });
  }
}

// class LocalisationBuffer {
//   final StringBuffer commonBuffer;
//   final Map<String, StringBuffer> languagesBuffers;
//
//   factory LocalisationBuffer(LocalisationDto localisation) {
//     final Map<String, StringBuffer> languagesBuffers = {};
//     for (final language in localisation.languages) {
//       languagesBuffers[language.key] = StringBuffer();
//     }
//     final commonBuffer = StringBuffer();
//     return LocalisationBuffer._(commonBuffer, languagesBuffers);
//   }
//
//   LocalisationBuffer._(this.commonBuffer, this.languagesBuffers);
//
//   StringBuffer get([String? language]) {
//     if (language == null) {
//       return commonBuffer;
//     }
//     return languagesBuffers[language]!;
//   }
//
//   void addCommon(String value) {
//     commonBuffer.write(value);
//   }
//
//   void addLanguage(String language, String value) {
//     languagesBuffers[language]?.write(value);
//   }
// }
