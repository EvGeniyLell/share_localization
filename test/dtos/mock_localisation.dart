import 'package:share_localisation/dtos/dtos.dart';

const localisationDto = LocalisationDto(
  name: 'test',
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
  localizations: loginMessageKeyLocalizations,
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
