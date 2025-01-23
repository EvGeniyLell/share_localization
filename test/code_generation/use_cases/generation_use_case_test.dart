import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:share_localization/code_generation/use_cases/batch_code_generation_use_case.dart';
import 'package:test/test.dart';

import '../../common/mocks.dart';

void main() {
  // Printer.debug = true;

  late List<InvocationCreateFile> virtualFiles;
  late FileService fileService;
  late BatchCodeGenerationUseCase generationUseCase;

  setUp(() {
    virtualFiles = [];
    fileService = MockFileService();
    generationUseCase = BatchCodeGenerationUseCase.all(
      fileService: fileService,
    );

    when(() {
      return fileService.createFile(
        path: any(named: 'path'),
        content: any(named: 'content'),
      );
    }).thenAnswer((invocation) async {
      virtualFiles.add(InvocationCreateFile(invocation));
    });

    when(() {
      return fileService.getFilesInDirectory(
        path: any(named: 'path'),
        extension: any(named: 'extension'),
      );
    }).thenAnswer((invocation) async {
      return <String>[
        'example/bundles/feature_a.json',
        'example/bundles/general.json',
      ].map(File.new).toList();
    });
  });

  group('BatchCodeGenerationUseCase', () {
    test('builder with settings', () async {
      final result = await generationUseCase('example/settings.json');
      expect(result.succeeded, isTrue);
      expect(virtualFiles.length, 14);
      expect(virtualFiles.map((f) => f.path), [
        'example/results/flutter/feature_a.dart',
        'example/results/flutter/feature_a_en.dart',
        'example/results/flutter/feature_a_ua.dart',
        'example/results/ios/FeatureA.xcstrings',
        'example/results/ios/FeatureA.swift',
        'example/results/android/featureA_en.xml',
        'example/results/android/featureA_ua.xml',
        'example/results/flutter/general.dart',
        'example/results/flutter/general_en.dart',
        'example/results/flutter/general_ua.dart',
        'example/results/ios/General.xcstrings',
        'example/results/ios/General.swift',
        'example/results/android/general_en.xml',
        'example/results/android/general_ua.xml',
      ]);

      for (final file in virtualFiles) {
        final expectedContent = await File(file.path).readAsString();
        expect(
          expectedContent.tremContent(),
          file.content.tremContent(),
          reason: file.toString(),
        );
      }
    });
  });
}
