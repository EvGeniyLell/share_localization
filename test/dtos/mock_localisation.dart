import 'package:share_localisation/dtos/dtos.dart';

const localisationDto = LocalisationDto(
  name: 'test_feature_a_localisation.json',
  languages: [
    localisationEnLanguage,
    localisationDeLanguage,
  ],
  keys: [
    loginMessageKey,
  ],
);

const localisationEnLanguage = LanguageDto(key: 'en');
const localisationDeLanguage = LanguageDto(key: 'de');
const localisationUaLanguage = LanguageDto(key: 'ua');

// -- loginMessage -------------------------------------------------------------

const loginMessageKey = LocalisationKeyDto(
  key: 'login_message',
  comment: 'This a body of login message.',
  arguments: loginMessageKeyArguments,
  translation: loginMessageKeyLocalizations,
);

const loginMessageKeyArguments = [
  LocalisationKeyArgumentDto(
    name: 'username',
    type: LocalisationKeyDtoType.string,
  ),
  LocalisationKeyArgumentDto(
    name: 'password',
    type: LocalisationKeyDtoType.string,
  ),
];

const loginMessageKeyLocalizations = [
  LocalisationKeyTranslationDto(
    languageKey: 'en',
    message: 'Hi {username}, your password is {password}',
  ),
  LocalisationKeyTranslationDto(
    languageKey: 'de',
    message: 'Heilegh {username}, dein passdahwordther ist {password}',
  ),
];

// -- loginTitle ---------------------------------------------------------------

const loginTitleKey = LocalisationKeyDto(
  key: 'login_title',
  comment: 'This is a title for login screen.',
  arguments: [],
  translation: [
    LocalisationKeyTranslationDto(
      languageKey: 'en',
      message: 'Login Page',
    ),
    LocalisationKeyTranslationDto(
      languageKey: 'de',
      message: 'Ther Loghingher Paghedguahter',
    ),
  ],
);
