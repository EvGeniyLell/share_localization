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

const localisationEnLanguage = LanguageDto(abbreviation: 'en');
const localisationDeLanguage = LanguageDto(abbreviation: 'de');
const localisationUaLanguage = LanguageDto(abbreviation: 'ua');

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
    key: 'en',
    message: 'Hi {username}, your password is {password}',
  ),
  LocalisationKeyTranslationDto(
    key: 'de',
    message: 'Heilegh {username}, dein passdahwordther ist {password}',
  ),
];
