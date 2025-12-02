import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:share_localization/code_generation/use_cases/flutter/flutter_code_generation_use_case.dart';
import 'package:test/test.dart';

import '../../common/mocks.dart';
import '../../localizations/mocks.dart';
import '../../settings/mocks.dart';

void main() {
  //Printer.debug = true;

  late List<InvocationCreateFile> virtualFiles;
  late FileService fileService;
  late FlutterCodeGenerationUseCase generationUseCase;

  setUp(() {
    virtualFiles = [];
    fileService = MockFileService();
    generationUseCase = FlutterCodeGenerationUseCase(fileService);

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
    test('generateCommon', () async {
      final result = generationUseCase.generateCommon(
        settingsDto.toPlatformSettingsDto()!,
        localizationDto.copyWith(keys: [loginMessageKey, loginTitleKey]),
      );

      final expectedContent = await File(
        'example/test_results/flutter/test_feature_a_localization.dart',
      ).readAsString();
      expect(expectedContent.tremContent(), result.tremContent());
    });

    test('generateLocale', () async {
      final result = generationUseCase.generateLocale(
        settingsDto.toPlatformSettingsDto()!,
        settingsEnLanguageDto,
        localizationDto.copyWith(keys: [loginMessageKey, loginTitleKey]),
      );

      final expectedContent = await File(
        'example/test_results/flutter/test_feature_a_localization_en.dart',
      ).readAsString();
      expect(expectedContent.tremContent(), result.tremContent());
    });

    test('generationUseCase', () async {
      final dtoTask = await generationUseCase(
        settingsDto,
        localizationDto.copyWith(keys: [loginMessageKey, loginTitleKey]),
      );
      expect(dtoTask.succeeded, true);
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
          reason: file.toString(),
        );
      }
    });
  });
}
