import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/utils/common.dart';

abstract class BuildLocalisationUseCase {
  const BuildLocalisationUseCase();

  AppTask<void> call(SettingsDto settings, LocalisationDto localisation);

  void createFile(String path, String content) {
    print('Creating file: $path');
    print(content);
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
