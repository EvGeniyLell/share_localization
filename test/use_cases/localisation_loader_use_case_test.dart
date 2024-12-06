import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/exceptions/exceptions.dart';
import 'package:share_localisation/use_cases/localisation_loader_use_case.dart';
import 'package:test/test.dart';

void main() {
  const loader = LocalisationLoaderUseCase();

  group('LocalisationLoaderUseCase', () {
    test('succeeded', () async {
      final dtoTask = await loader('test/sources/bundles/feature_a.json');
      expect(dtoTask.succeeded, true);
      expect(dtoTask.data, isA<LocalisationDto>());

      final dto = dtoTask.data;

      expect(dto.name, 'feature_a.json');
      expect(dto.languages, hasLength(2));
      expect(dto.languages.first.key, 'en');

      expect(dto.keys, hasLength(3));
      expect(dto.keys.first.key, 'login_message');
      expect(dto.keys.first.arguments, hasLength(2));
    });

    test('failed', () async {
      final dtoTask = await loader('test/sources/sl_settings.json');
      expect(dtoTask.failed, true);
      expect(dtoTask.exception, isA<UnexpectedException>());
    });
  });
}
