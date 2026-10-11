import 'package:test/test.dart';

import '../../common/mocks.dart';
import '../../localizations/mocks.dart';
import '../../settings/mocks.dart';

void main() {
  // Printer.debug = true;

  const verification = VerificationLocalizationUseCase();

  group('VerificationLocalizationUseCase', () {
    group('checkLocalization', () {
      test('succeeded', () async {
        final result = verification.checkLocalization(
          settingsDto,
          localizationDto,
        );
        expect(result, []);
      });

      test('succeeded even localization has more languages', () async {
        final result = verification.checkLocalization(
          settingsDto,
          localizationDto.copyWith(
            languages: [...localizationDto.languages, localizationUaLanguage],
          ),
        );
        expect(result, []);
      });

      test('failed with missingLanguage', () async {
        final result = verification.checkLocalization(
          settingsDto.copyWith(
            languages: [...settingsDto.languages, settingsUaLanguageDto],
          ),
          localizationDto,
        );
        expect(result, hasLength(1));
        expect(
          result.first,
          predicate((VerificationLocalizationMissingLanguageException e) {
            return e.language == settingsUaLanguageDto.key;
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
        final (left, common, right) = [
          1,
          2,
          3,
          4,
          5,
        ].intersection([3, 4, 5, 6, 7]);
        expect(left, [1, 2]);
        expect(common, [3, 4, 5]);
        expect(right, [6, 7]);
      });

      test('intersection - BA', () {
        final (left, common, right) = [
          3,
          4,
          5,
          6,
          7,
        ].intersection([1, 2, 3, 4, 5]);
        expect(left, [6, 7]);
        expect(common, [3, 4, 5]);
        expect(right, [1, 2]);
      });

      test('succeeded', () {
        final result = verification.checkKeyArguments(
          settingsDto,
          localizationDto,
          loginMessageKey,
        );
        expect(result, []);
      });

      test('failed with extraArgument', () {
        const extraArgumentA = LocalizationKeyArgumentDto(
          name: 'email',
          type: LocalizationKeyDtoType.string,
        );
        const extraArgumentB = LocalizationKeyArgumentDto(
          name: 'role',
          type: LocalizationKeyDtoType.string,
        );
        final result = verification.checkKeyArguments(
          settingsDto,
          localizationDto,
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
            predicate((VerificationLocalizationExtraArgumentException e) {
              return [
                    extraArgumentA.name,
                    extraArgumentB.name,
                  ].contains(e.argument) &&
                  e.key == loginMessageKey.key &&
                  [
                    localizationEnLanguage.key,
                    localizationDeLanguage.key,
                  ].contains(e.language);
            }),
          );
        }
      });

      test('failed with missingArgument', () {
        const missingArgumentName = 'dayType';
        const missingArgumentEnTranslation = LocalizationKeyTranslationDto(
          languageKey: 'en',
          message:
              'Hi {username}, your password is {password}.\n'
              'Have a {$missingArgumentName} day!',
        );
        const missingArgumentDeTranslation = LocalizationKeyTranslationDto(
          languageKey: 'de',
          message:
              'Heilegh {username}, dein passdahwordther ist {password}.\n'
              'Habe ein {$missingArgumentName} Tag!',
        );
        final result = verification.checkKeyArguments(
          settingsDto,
          localizationDto,
          loginMessageKey.copyWith(
            translations: [
              missingArgumentEnTranslation,
              missingArgumentDeTranslation,
            ],
          ),
        );
        expect(result, hasLength(2));
        for (final exception in result) {
          expect(
            exception,
            predicate((VerificationLocalizationMissingArgumentException e) {
              return e.argument == missingArgumentName &&
                  e.key == loginMessageKey.key &&
                  [
                    localizationEnLanguage.key,
                    localizationDeLanguage.key,
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
          localizationDto,
          loginMessageKey,
        );
        expect(result, []);
      });

      test('failed with missingArgument', () {
        final result = verification.checkKeyTranslations(
          settingsDto,
          localizationDto,
          loginMessageKey.copyWith(
            translations: [loginMessageKeyLocalizations[0]],
          ),
        );
        expect(result, hasLength(1));
        for (final exception in result) {
          expect(
            exception,
            predicate((VerificationLocalizationMissingTranslationException e) {
              return e.key == loginMessageKey.key &&
                  e.language == localizationDeLanguage.key;
            }),
          );
        }
      });
    });

    group('call', () {
      const extraArgument = LocalizationKeyArgumentDto(
        name: 'email',
        type: LocalizationKeyDtoType.string,
      );

      // One extra argument, reported once per translation (en and de).
      final withExtraArgument = localizationDto.copyWith(
        keys: [
          loginMessageKey.copyWith(
            arguments: [...loginMessageKeyArguments, extraArgument],
          ),
        ],
      );

      // The extra argument is reported for en only, and de is missing.
      final withExtraArgumentAndMissingTranslation = localizationDto.copyWith(
        keys: [
          loginMessageKey.copyWith(
            arguments: [...loginMessageKeyArguments, extraArgument],
            translations: [loginMessageKeyLocalizations[0]],
          ),
        ],
      );

      test('succeeded for a valid localization', () async {
        final task = await verification(settingsDto, localizationDto);

        expect(task.succeeded, true);
      });

      test('failed with extraArgument when it is not skipped', () async {
        final task = await verification(settingsDto, withExtraArgument);

        expect(task.failed, true);
        expect(
          task.exception,
          isA<CompositeException>().having((e) => e.exceptions, 'exceptions', [
            isA<VerificationLocalizationExtraArgumentException>(),
            isA<VerificationLocalizationExtraArgumentException>(),
          ]),
        );
      });

      test('succeeded when extraArgument is in skipErrorTypes', () async {
        const skippingVerification = VerificationLocalizationUseCase(
          skipErrorTypes: [VerificationLocalizationExtraArgumentException],
        );

        final task = await skippingVerification(settingsDto, withExtraArgument);

        expect(task.succeeded, true);
      });

      test('returns skipped extraArgument exceptions as data', () async {
        const skippingVerification = VerificationLocalizationUseCase(
          skipErrorTypes: [VerificationLocalizationExtraArgumentException],
        );

        final task = await skippingVerification(settingsDto, withExtraArgument);

        expect(task.succeeded, true);
        expect(task.data, hasLength(2));
        expect(
          task.data,
          everyElement(isA<VerificationLocalizationExtraArgumentException>()),
        );
      });

      test('returns an empty list when nothing is skipped', () async {
        final task = await verification(settingsDto, localizationDto);

        expect(task.succeeded, true);
        expect(task.data, isEmpty);
      });

      test('skipErrorTypes does not hide other error types', () async {
        const skippingVerification = VerificationLocalizationUseCase(
          skipErrorTypes: [VerificationLocalizationExtraArgumentException],
        );

        final task = await skippingVerification(
          settingsDto,
          withExtraArgumentAndMissingTranslation,
        );

        expect(task.failed, true);
        expect(
          task.exception,
          isA<CompositeException>().having((e) => e.exceptions, 'exceptions', [
            isA<VerificationLocalizationMissingTranslationException>()
                .having((e) => e.key, 'key', loginMessageKey.key)
                .having(
                  (e) => e.language,
                  'language',
                  localizationDeLanguage.key,
                ),
          ]),
        );
      });
    });
  });
}
