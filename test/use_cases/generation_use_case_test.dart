import 'package:share_localization/code_generation/use_cases/batch_code_generation_use_case.dart';
import 'package:test/test.dart';

void main() {
  final builder = BatchCodeGenerationUseCase.all();

  group('BuildAllUseCase', () {
    test('builder with sl_settings', () async {
      final result = await builder('test/sources/settings.json');
      expect(result.succeeded, isTrue);
    });
  });
}
