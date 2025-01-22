import 'package:share_localization/use_cases/ios/build_ios_localization_use_case.dart';
import 'package:test/test.dart';

import '../dtos/mock_localization.dart';
import '../dtos/mock_settings.dart';

void main() {
  const builder = BuildIosLocalizationUseCase();

  group('BuildIosLocalizationUseCase', () {
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
        final result = key.iosXCStringKey();
        expect(result, anyOf('login_message%@%@', 'login_title'));
      }
    });

    test('buildXCStringsItem', () async {
      final keys = [
        loginMessageKey,
        loginTitleKey,
      ];
      for (final key in keys) {
        final result = builder.buildXCStringsItem(key);
        print(result);
        //expect(result, anyOf('login_message%@%@', 'login_title'));
      }
    });

    test('buildXCStrings', () async {
      final result = builder.buildXCStrings(
        settingsDto,
        localizationDto.copyWith(
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
        localizationDto.copyWith(
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
        localizationDto.copyWith(
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
