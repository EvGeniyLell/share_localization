library;

import 'package:share_localization/localizations/localizations.dart';

export 'package:share_localization/localizations/localizations.dart';

const localizationDto = LocalizationDto(
  name: 'test_feature_A.json',
  languages: [localizationEnLanguage, localizationDeLanguage],
  keys: [loginMessageKey],
);

// Covers int and double arguments, with placeholders in a different order than
// the declared arguments. Argument names are single words on purpose.
const numericLocalizationDto = LocalizationDto(
  name: 'test_numbers.json',
  languages: [localizationEnLanguage, localizationDeLanguage],
  keys: [fileReportKey],
);

const localizationEnLanguage = LanguageDto(key: 'en');
const localizationDeLanguage = LanguageDto(key: 'de');
const localizationUaLanguage = LanguageDto(key: 'ua');

// -- loginMessage -------------------------------------------------------------

const loginMessageKey = LocalizationKeyDto(
  key: 'login_message',
  comment: 'This a body of login message.',
  arguments: loginMessageKeyArguments,
  translations: loginMessageKeyLocalizations,
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
  translations: [
    LocalizationKeyTranslationDto(languageKey: 'en', message: 'Login Page'),
    LocalizationKeyTranslationDto(
      languageKey: 'de',
      message: 'Ther Loghingher Paghedguahter',
    ),
  ],
);

// -- fileReport ---------------------------------------------------------------

const fileReportKey = LocalizationKeyDto(
  key: 'file_report',
  comment: 'This is a report about a file.',
  arguments: [
    LocalizationKeyArgumentDto(
      name: 'title',
      type: LocalizationKeyDtoType.string,
    ),
    LocalizationKeyArgumentDto(
      name: 'size',
      type: LocalizationKeyDtoType.double,
    ),
    LocalizationKeyArgumentDto(
      name: 'pages',
      type: LocalizationKeyDtoType.int,
    ),
  ],
  translations: [
    LocalizationKeyTranslationDto(
      languageKey: 'en',
      message: 'File {title} has {pages} pages and weighs {size} MB',
    ),
    LocalizationKeyTranslationDto(
      languageKey: 'de',
      message: 'Datei {title} hat {pages} Seiten und wiegt {size} MB',
    ),
  ],
);
