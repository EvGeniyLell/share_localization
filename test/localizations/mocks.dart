library;

import 'package:share_localization/localizations/localizations.dart';

export 'package:share_localization/localizations/localizations.dart';

const localizationDto = LocalizationDto(
  name: 'test_feature_a_localization.json',
  languages: [localizationEnLanguage, localizationDeLanguage],
  keys: [loginMessageKey],
);

const localizationEnLanguage = LanguageDto(key: 'en');
const localizationDeLanguage = LanguageDto(key: 'de');
const localizationUaLanguage = LanguageDto(key: 'ua');

// -- loginMessage -------------------------------------------------------------

const loginMessageKey = LocalizationKeyDto(
  key: 'login_message',
  comment: 'This a body of login message.',
  arguments: loginMessageKeyArguments,
  translation: loginMessageKeyLocalizations,
);

const loginMessageKeyArguments = [
  LocalizationKeyArgumentDto(
    name: 'username',
    type: LocalizationKeyDtoType.string,
  ),
  LocalizationKeyArgumentDto(
    name: 'password',
    type: LocalizationKeyDtoType.string,
  ),
];

const loginMessageKeyLocalizations = [
  LocalizationKeyTranslationDto(
    languageKey: 'en',
    message: 'Hi {username}, your password is {password}',
  ),
  LocalizationKeyTranslationDto(
    languageKey: 'de',
    message: 'Heilegh {username}, dein passdahwordther ist {password}',
  ),
];

// -- loginTitle ---------------------------------------------------------------

const loginTitleKey = LocalizationKeyDto(
  key: 'login_title',
  comment: 'This is a title for login screen.',
  arguments: [],
  translation: [
    LocalizationKeyTranslationDto(languageKey: 'en', message: 'Login Page'),
    LocalizationKeyTranslationDto(
      languageKey: 'de',
      message: 'Ther Loghingher Paghedguahter',
    ),
  ],
);
