import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/exceptions/exceptions.dart';
import 'package:share_localisation/use_cases/settings_loader_use_case.dart';
import 'package:test/test.dart';

void main() {
  final loader = SettingsLoaderUseCase();

  group('SettingsLoaderUseCase', () {
    test('succeeded', () async {
      final dtoTask = await loader('test/sources/sl_settings.json');
      expect(dtoTask.succeeded, true);
      expect(dtoTask.data, isA<SettingsDto>());

      final dto = dtoTask.data;

      expect(dto.languages, hasLength(2));
      expect(dto.languages[0].abbreviation, 'en');
      expect(dto.languages[1].abbreviation, 'de');

      expect(dto.sourcesFolder, 'test/sources/bundles');

      expect(dto.ios, isA<IosSettingsDto>());
      expect(dto.ios.destinationFolder, 'test/ios');

      expect(dto.android, isA<AndroidSettingsDto>());
      expect(dto.android.destinationFolder, 'test/android');

      expect(dto.flutter, isA<FlutterSettingsDto>());
      expect(dto.flutter.destinationFolder, 'test/flutter');
    });

    test('failed', () async {
      final dtoTask = await loader('test/sources/bundles/feature_a.json');
      expect(dtoTask.failed, true);
      expect(dtoTask.exception, isA<UnexpectedException>());
    });
  });
}
