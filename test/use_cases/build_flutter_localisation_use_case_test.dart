import 'package:share_localisation/use_cases/build_flutter_localisation_use_case.dart';
import 'package:test/test.dart';

import '../dtos/mock_localisation.dart';
import '../dtos/mock_settings.dart';

void main() {
  const builder = BuildFlutterLocalisationUseCase();

  group('BuildFlutterLocalisationUseCase', () {
    test('buildCommon', () async {
      final commonData = builder.buildCommon(
        settingsDto,
        localisationDto.copyWith(
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
        localisationDto.copyWith(
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
