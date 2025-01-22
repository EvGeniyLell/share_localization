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

const settingEnLanguageDto = LanguageDto(key: 'en');
const settingDeLanguageDto = LanguageDto(key: 'de');
const settingUaLanguageDto = LanguageDto(key: 'ua');

const iosSettingsDto = IosSettingsDto(
  destinationFolder: 'test/ios',
  bundleName: 'testBundle',
);
const androidSettingsDto = AndroidSettingsDto(
  destinationFolder: 'test/android',
);
const flutterSettingsDto = FlutterSettingsDto(
  destinationFolder: 'test/flutter',
);
