import 'package:test/test.dart';

import '../../common/mocks.dart';
import '../../settings/mocks.dart';

void main() {
  // Printer.debug = true;

  const loader = SettingsLoaderUseCase();

  group('SettingsLoaderUseCase', () {
    test('succeeded', () async {
      final dtoTask = await loader('example/settings.json');
      expect(dtoTask.succeeded, true);
      expect(dtoTask.data, isA<SettingsDto>());

      final dto = dtoTask.data;

      expect(dto.languages, hasLength(2));
      expect(dto.languages[0].key, 'en');
      expect(dto.languages[1].key, 'ua');

      expect(dto.sourcesFolder, 'bundles');

      const pathPrefix = '../example/results';
      expect(dto.ios, isA<IosOptionsDto>());
      expect(dto.ios?.destinationFolder, '$pathPrefix/ios');

      expect(dto.android, isA<AndroidOptionsDto>());
      expect(dto.android?.destinationFolder, '$pathPrefix/android/values');

      expect(dto.flutter, isA<FlutterOptionsDto>());
      expect(dto.flutter?.destinationFolder, '$pathPrefix/flutter');
    });

    test('failed', () async {
      final dtoTask = await loader('example/bundles/feature_a.json');
      expect(dtoTask.failed, true);
      expect(dtoTask.exception, isA<UnexpectedException>());
    });
  });
}
