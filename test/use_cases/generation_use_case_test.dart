import 'package:share_localization/use_cases/generation_all_use_case.dart';
import 'package:test/test.dart';

void main() {
  final builder = GenerationUseCase.all();

  group('BuildAllUseCase', () {
    test('builder with sl_settings', () async {
      final result = await builder('test/sources/settings.json');
      expect(result.succeeded, isTrue);
    });
  });
}
