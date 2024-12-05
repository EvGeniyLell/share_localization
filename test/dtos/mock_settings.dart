import 'package:share_localisation/dtos/dtos.dart';

const settingsDto = SettingsDto(
  languages: [
    settingEnLanguageDto,
    settingDeLanguageDto,
  ],
  sourcesFolder: 'test/sources/bundles',
  ios: iosSettingsDto,
  android: androidSettingsDto,
  flutter: flutterSettingsDto,
);

const settingEnLanguageDto = LanguageDto(abbreviation: 'en');
const settingDeLanguageDto = LanguageDto(abbreviation: 'de');
const settingUaLanguageDto = LanguageDto(abbreviation: 'ua');

const iosSettingsDto = IosSettingsDto(
  destinationFolder: 'test/ios',
);
const androidSettingsDto = AndroidSettingsDto(
  destinationFolder: 'test/android',
);
const flutterSettingsDto = FlutterSettingsDto(
  destinationFolder: 'test/flutter',
);
