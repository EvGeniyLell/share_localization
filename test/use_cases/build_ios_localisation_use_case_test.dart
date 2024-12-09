import 'package:share_localisation/use_cases/build_ios_localisation_use_case.dart';
import 'package:test/test.dart';

import '../dtos/mock_localisation.dart';
import '../dtos/mock_settings.dart';

void main() {
  const builder = BuildIosLocalisationUseCase();

  group('BuildIosLocalisationUseCase', () {
    test('iosMessage', () {
      for (final translation in loginMessageKeyLocalizations) {
        final result = translation.iosMessage(loginMessageKeyArguments);
        expect(
          result,
          anyOf(
            r'Hi %1$@, your password is %2$@',
            r'Heilegh %1$@, dein passdahwordther ist %2$@',
          ),
        );
      }
    });

    test('iosKey', () {
      final keys = [
        loginMessageKey,
        loginTitleKey,
      ];
      for (final key in keys) {
        final result = key.iosCXStringKey();
        expect(result, anyOf('login_message%@%@', 'login_title'));
      }
    });

    test('buildCXStringsItem', () async {
      final keys = [
        loginMessageKey,
        loginTitleKey,
      ];
      for (final key in keys) {
        final result = builder.buildCXStringsItem(key);
        print(result);
        //expect(result, anyOf('login_message%@%@', 'login_title'));
      }
    });

    test('buildCXStrings', () async {
      final result = builder.buildCXStrings(
        settingsDto,
        localisationDto.copyWith(
          keys: [
            loginMessageKey,
            loginTitleKey,
          ],
        ),
      );
      print(result);
    });

    test('buildSwift', () async {
      final result = builder.buildSwift(
        settingsDto,
        localisationDto.copyWith(
          keys: [
            loginMessageKey,
            loginTitleKey,
          ],
        ),
      );
      print(result);
    });

    test('success', () async {
      final dtoTask = await builder(
        settingsDto,
        localisationDto.copyWith(
          keys: [
            loginMessageKey,
            loginTitleKey,
          ],
        ),
      );
      expect(dtoTask.succeeded, true);
    });
  });
}
