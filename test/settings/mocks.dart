library;

import 'package:share_localization/settings/settings.dart';

export 'package:share_localization/settings/settings.dart';

const settingsDto = SettingsDto(
  languages: [settingsEnLanguageDto, settingsDeLanguageDto],
  sourcesFolder: 'example/bundles',
  ios: iosOptionsDto,
  android: androidOptionsDto,
  flutter: flutterOptionsDto,
);

// copyWith cannot reset a block to null, so these are built directly.
const settingsDtoWithoutIos = SettingsDto(
  languages: [settingsEnLanguageDto, settingsDeLanguageDto],
  sourcesFolder: 'example/bundles',
  ios: null,
  android: androidOptionsDto,
  flutter: flutterOptionsDto,
);

const settingsDtoWithoutAndroid = SettingsDto(
  languages: [settingsEnLanguageDto, settingsDeLanguageDto],
  sourcesFolder: 'example/bundles',
  ios: iosOptionsDto,
  android: null,
  flutter: flutterOptionsDto,
);

const settingsDtoWithoutFlutter = SettingsDto(
  languages: [settingsEnLanguageDto, settingsDeLanguageDto],
  sourcesFolder: 'example/bundles',
  ios: iosOptionsDto,
  android: androidOptionsDto,
  flutter: null,
);

const settingsEnLanguageDto = SettingsLanguageDto(key: 'en');
const settingsDeLanguageDto = SettingsLanguageDto(key: 'de');
const settingsUaLanguageDto = SettingsLanguageDto(key: 'ua');

const iosOptionsDto = IosOptionsDto(
  bundleName: 'testBundle',
  classAccessLevel: 'internal',
  destinationFolder: 'example/test_results/ios',
);
const androidOptionsDto = AndroidOptionsDto(
  useCamelCase: true,
  useFilePrefixForKeys: true,
  destinationFolder: 'example/test_results/android/values',
);
const flutterOptionsDto = FlutterOptionsDto(
  destinationFolder: 'example/test_results/flutter',
);
