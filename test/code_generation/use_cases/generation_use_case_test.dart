import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:share_localization/code_generation/use_cases/batch_code_generation_use_case.dart';
import 'package:test/test.dart';

import '../../common/mocks.dart';

void main() {
  late List<InvocationCreateFile> virtualFiles;
  late FileService fileService;
  late BatchCodeGenerationUseCase generationUseCase;


  setUp(() {
    virtualFiles = [];
    fileService = MockFileService();
    generationUseCase = BatchCodeGenerationUseCase.all(fileService: fileService);

    when(() {
      return fileService.createFile(
        path: any(named: 'path'),
        content: any(named: 'content'),
      );
    }).thenAnswer((invocation) async {
      virtualFiles.add(InvocationCreateFile(invocation));
    });
  });

  group('BatchCodeGenerationUseCase', () {
    test('builder with settings', () async {
      final result = await generationUseCase('example/settings.json');
      print(result.exception);
      expect(result.succeeded, isTrue);
      expect(virtualFiles.length, 3);
      expect(virtualFiles.map((f) => f.path), [
        'example/test_results/flutter/test_feature_a_localization.dart',
        'example/test_results/flutter/test_feature_a_localization_en.dart',
        'example/test_results/flutter/test_feature_a_localization_de.dart',
      ]);

      for (final file in virtualFiles) {
        final expectedContent = await File(file.path).readAsString();
        expect(
          expectedContent.tremContent(),
          file.content.tremContent(),
          reason: file.path,
        );
      }
    });
  });
}
