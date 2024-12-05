import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/exceptions/exceptions.dart';
import 'package:share_localisation/use_cases/verification_localisation_use_case.dart';
import 'package:test/test.dart';

import '../dtos/mock_localisation.dart';
import '../dtos/mock_settings.dart';

void main() {
  final verification = VerificationLocalisationUseCase();

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
          predicate((VerificationLocalisationException e) {
            return e.type ==
                    VerificationLocalisationExceptionType.missingLanguage &&
                e.key == settingUaLanguageDto.key;
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

      test('s1', () {
        final result = verification.checkKeyArguments(
          settingsDto,
          loginMessageKey.copyWith(
            arguments: [
              ...loginMessageKeyArguments,
              const LocalisationKeyArgumentDto(
                name: 'email',
                type: LocalisationKeyDtoType.string,
              ),
            ],
          ),
        );
        expect(result, [2]);
      });

      // test('s', () {
      //   final result =
      //       verification.checkKeyArguments(settingsDto, loginMessageKey);
      //   expect(result, [2]);
      // });
    });
    // test('failed', () async {
    //   final dtoTask = await loader('test/sources/bundles/feature_a.json');
    //   expect(dtoTask.failed, true);
    //   expect(dtoTask.exception, isA<UnexpectedException>());
    // });
  });
}
