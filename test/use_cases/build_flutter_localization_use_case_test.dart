import 'package:share_localization/use_cases/flutter/flutter_code_generation_use_case.dart';
import 'package:test/test.dart';

import '../dtos/mock_localization.dart';
import '../dtos/mock_settings.dart';

void main() {
  const builder = FlutterCodeGenerationUseCase();

  group('BuildFlutterLocalizationUseCase', () {
    test('buildCommon', () async {
      final commonData = builder.buildCommon(
        settingsDto,
        localizationDto.copyWith(
          keys: [
            loginMessageKey,
            loginTitleKey,
          ],
        ),
      );
      print(commonData);
    });

    test('buildLocale', () async {
      final data = builder.buildLocale(
        settingsDto,
        localizationDto.copyWith(
          keys: [
            loginMessageKey,
            loginTitleKey,
          ],
        ),
        settingEnLanguageDto,
      );
      print(data);
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
