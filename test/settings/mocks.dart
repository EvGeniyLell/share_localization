library;

import 'package:share_localization/settings/settings.dart';

export 'package:share_localization/settings/settings.dart';

const settingsDto = SettingsDto(
  languages: [
    settingsEnLanguageDto,
    settingsDeLanguageDto,
  ],
  sourcesFolder: 'example/bundles',
  ios: iosOptionsDto,
  android: androidOptionsDto,
  flutter: flutterOptionsDto,
);

const settingsEnLanguageDto = LanguageDto(key: 'en');
const settingsDeLanguageDto = LanguageDto(key: 'de');
const settingsUaLanguageDto = LanguageDto(key: 'ua');

const iosOptionsDto = IosOptionsDto(
  bundleName: 'testBundle',
  destinationFolder: 'example/test_results/ios',
);
const androidOptionsDto = AndroidOptionsDto(
  useCamelCase: true,
  destinationFolder: 'example/test_results/android',
);
const flutterOptionsDto = FlutterOptionsDto(
  destinationFolder: 'example/test_results/flutter',
);
