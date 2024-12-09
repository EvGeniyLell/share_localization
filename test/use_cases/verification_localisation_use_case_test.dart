import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/exceptions/exceptions.dart';
import 'package:share_localisation/use_cases/verification_localisation_use_case.dart';
import 'package:test/test.dart';

import '../dtos/mock_localisation.dart';
import '../dtos/mock_settings.dart';

void main() {
  const verification = VerificationLocalisationUseCase();

  group('VerificationLocalisationUseCase', () {
    group('checkLocalisation', () {
      test('succeeded', () async {
        final result =
            verification.checkLocalisation(settingsDto, localisationDto);
        expect(result, []);
      });

      test('succeeded even localisation has more languages', () async {
        final result = verification.checkLocalisation(
          settingsDto,
          localisationDto.copyWith(
            languages: [...localisationDto.languages, localisationUaLanguage],
          ),
        );
        expect(result, []);
      });

      test('failed with missingLanguage', () async {
        final result = verification.checkLocalisation(
          settingsDto.copyWith(
            languages: [...settingsDto.languages, settingUaLanguageDto],
          ),
          localisationDto,
        );
        expect(result, hasLength(1));
        expect(
          result.first,
          predicate((VerificationLocalisationMissingLanguageException e) {
            return e.language == settingUaLanguageDto.key;
          }),
        );
      });
    });

    group('checkKeyArguments', () {
      test('getMessageArguments', () {
        loginMessageKeyLocalizations.forEach((localization) {
          final result = localization.message.getMessageArguments();
          expect(result, ['username', 'password']);
        });
      });

      test('intersection - AB', () {
        final (left, common, right) =
            [1, 2, 3, 4, 5].intersection([3, 4, 5, 6, 7]);
        expect(left, [1, 2]);
        expect(common, [3, 4, 5]);
        expect(right, [6, 7]);
      });

      test('intersection - BA', () {
        final (left, common, right) =
            [3, 4, 5, 6, 7].intersection([1, 2, 3, 4, 5]);
        expect(left, [6, 7]);
        expect(common, [3, 4, 5]);
        expect(right, [1, 2]);
      });

      test('succeeded', () {
        final result = verification.checkKeyArguments(
          settingsDto,
          localisationDto,
          loginMessageKey,
        );
        expect(result, []);
      });

      test('failed with extraArgument', () {
        const extraArgumentA = LocalisationKeyArgumentDto(
          name: 'email',
          type: LocalisationKeyDtoType.string,
        );
        const extraArgumentB = LocalisationKeyArgumentDto(
          name: 'role',
          type: LocalisationKeyDtoType.string,
        );
        final result = verification.checkKeyArguments(
          settingsDto,
          localisationDto,
          loginMessageKey.copyWith(
            arguments: [
              ...loginMessageKeyArguments,
              extraArgumentA,
              extraArgumentB,
            ],
          ),
        );
        expect(result, hasLength(4));
        for (final exception in result) {
          expect(
            exception,
            predicate((VerificationLocalisationExtraArgumentException e) {
              return [
                    extraArgumentA.name,
                    extraArgumentB.name,
                  ].contains(e.argument) &&
                  e.key == loginMessageKey.key &&
                  [
                    localisationEnLanguage.key,
                    localisationDeLanguage.key,
                  ].contains(e.language);
            }),
          );
        }
      });

      test('failed with missingArgument', () {
        const missingArgumentName = 'dayType';
        const missingArgumentEnTranslation = LocalisationKeyTranslationDto(
          languageKey: 'en',
          message: 'Hi {username}, your password is {password}.\n'
              'Have a {$missingArgumentName} day!',
        );
        const missingArgumentDeTranslation = LocalisationKeyTranslationDto(
          languageKey: 'de',
          message: 'Heilegh {username}, dein passdahwordther ist {password}.\n'
              'Habe ein {$missingArgumentName} Tag!',
        );
        final result = verification.checkKeyArguments(
          settingsDto,
          localisationDto,
          loginMessageKey.copyWith(
            translation: [
              missingArgumentEnTranslation,
              missingArgumentDeTranslation,
            ],
          ),
        );
        expect(result, hasLength(2));
        for (final exception in result) {
          expect(
            exception,
            predicate((VerificationLocalisationMissingArgumentException e) {
              return e.argument == missingArgumentName &&
                  e.key == loginMessageKey.key &&
                  [
                    localisationEnLanguage.key,
                    localisationDeLanguage.key,
                  ].contains(e.language);
            }),
          );
        }
      });
    });

    group('checkKeyTranslations', () {
      test('succeeded', () {
        final result = verification.checkKeyTranslations(
          settingsDto,
          localisationDto,
          loginMessageKey,
        );
        expect(result, []);
      });

      test('failed with missingArgument', () {
        final result = verification.checkKeyTranslations(
          settingsDto,
          localisationDto,
          loginMessageKey.copyWith(
            translation: [
              loginMessageKeyLocalizations[0],
            ],
          ),
        );
        expect(result, hasLength(1));
        for (final exception in result) {
          expect(
            exception,
            predicate((VerificationLocalisationMissingTranslationException e) {
              return e.key == loginMessageKey.key &&
                  e.language == localisationDeLanguage.key;
            }),
          );
        }
      });
    });
  });
}
