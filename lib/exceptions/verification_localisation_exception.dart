import 'app_exception.dart';

class VerificationLocalisationException implements AppException {
  final VerificationLocalisationExceptionType type;
  final String message;
  final String? key;

  VerificationLocalisationException(this.type, this.message, {this.key});

  @override
  String toString() {
    return '$VerificationLocalisationException: $type'
        '${key == null ? '' : '($key)'}'
        ', $message';
  }
}

enum VerificationLocalisationExceptionType {
  missingLanguage,
  missingArgument,

  // missingKey,
  // missingValue,
  // missingAbbreviation,
  // missingSourcesFolder,
  // missingDestinationFolder,
  // missingIosSettings,
  // missingAndroidSettings,
  // missingFlutterSettings,
  // missingLanguages,
  // missingLanguageAbbreviation,
  // missingLanguageAbbreviations,
  // missingLanguageDto,
  // missingSettingsDto,
  // missingPlatformSettingsDto,
  // missingIosSettingsDto,
  // missingAndroidSettingsDto,
  // missingFlutterSettingsDto,
  // missingLanguageDtoAbbreviation,
  // missingLanguageDtoAbbreviations,
  // missingSettingsDtoLanguages,
  // missingSettingsDtoSourcesFolder,
  // missingSettingsDtoIos,
  // missingSettingsDtoAndroid,
  // missingSettingsDtoFlutter,
  // missingPlatformSettingsDtoDestinationFolder,
  // missingIosSettingsDtoDestinationFolder,
  // missingAndroidSettingsDtoDestinationFolder,
  // missingFlutterSettingsDtoDestinationFolder,
}