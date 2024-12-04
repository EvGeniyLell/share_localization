import 'package:share_localisation/dtos/language_dto.dart';
import 'package:share_localisation/dtos/localisation_key_argument_dto.dart';
import 'package:share_localisation/dtos/localisation_key_dto.dart';
import 'package:share_localisation/dtos/localisation_key_translation_dto.dart';

export 'package:share_localisation/dtos/language_dto.dart';
export 'package:share_localisation/dtos/localisation_key_argument_dto.dart';
export 'package:share_localisation/dtos/localisation_key_dto.dart';
export 'package:share_localisation/dtos/localisation_key_translation_dto.dart';

const bundleLanguage = LanguageDto(
  abbreviation: 'en',
);

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
    message: 'Hi \$username, your password is \$password',
  ),
  LocalisationKeyTranslationDto(
    key: 'de',
    message: 'Heilegh \$username, dein passdahwordther ist \$password',
  ),
];
