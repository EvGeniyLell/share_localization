import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:share_localization/code_generation/use_cases/android/android_code_generation_use_case.dart';
import 'package:test/test.dart';

import '../../common/mocks.dart';
import '../../localizations/mocks.dart';
import '../../settings/mocks.dart';

void main() {
  //Printer.debug = true;

  late List<InvocationCreateFile> virtualFiles;
  late FileService fileService;
  late AndroidCodeGenerationUseCase generationUseCase;

  setUp(() {
    virtualFiles = [];
    fileService = MockFileService();
    generationUseCase = AndroidCodeGenerationUseCase(fileService);

    when(() {
      return fileService.createFile(
        path: any(named: 'path'),
        content: any(named: 'content'),
      );
    }).thenAnswer((invocation) async {
      virtualFiles.add(InvocationCreateFile(invocation));
    });
  });

  group('FlutterCodeGenerationUseCase', () {
    test('generateXml', () async {
      final result = generationUseCase.generateXml(
        settingsDto,
        settingsEnLanguageDto,
        localizationDto.copyWith(
          keys: [
            loginMessageKey,
            loginTitleKey,
          ],
        ),
      );

      final expectedContent = await File(
        'example/test_results/android/testFeatureALocalization_en.xml',
      ).readAsString();
      expect(expectedContent.tremContent(), result.tremContent());
    });

    test('generationUseCase', () async {
      final dtoTask = await generationUseCase(
        settingsDto,
        localizationDto.copyWith(
          keys: [
            loginMessageKey,
            loginTitleKey,
          ],
        ),
      );
      expect(dtoTask.succeeded, true);
      expect(virtualFiles.length, 2);
      expect(virtualFiles.map((f) => f.path), [
        'example/test_results/android/testFeatureALocalization_en.xml',
        'example/test_results/android/testFeatureALocalization_de.xml',
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
