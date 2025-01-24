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
    late SettingsDto customSettingsDto;

    group('useCamelCase: true', () {
      setUp(() {
        customSettingsDto = settingsDto.copyWith(
          android: const AndroidOptionsDto(
            useCamelCase: true,
            destinationFolder: 'example/test_results/android/values',
          ),
        );
      });

      test('generateXml', () async {
        final result = generationUseCase.generateXml(
          customSettingsDto,
          settingsEnLanguageDto,
          localizationDto.copyWith(
            keys: [
              loginMessageKey,
              loginTitleKey,
            ],
          ),
        );

        final expectedContent = await File(
          'example/test_results/android/values/testFeatureALocalization.xml',
        ).readAsString();
        expect(expectedContent.tremContent(), result.tremContent());
      });

      test('generationUseCase', () async {
        final dtoTask = await generationUseCase(
          customSettingsDto,
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
          'example/test_results/android/values/testFeatureALocalization.xml',
          'example/test_results/android/values_de/testFeatureALocalization.xml',
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

    group('useCamelCase: false', () {
      setUp(() {
        customSettingsDto = settingsDto.copyWith(
          android: const AndroidOptionsDto(
            useCamelCase: false,
            destinationFolder: 'example/test_results/android/values',
          ),
        );
      });

      test('generateXml', () async {
        final result = generationUseCase.generateXml(
          customSettingsDto,
          settingsEnLanguageDto,
          localizationDto.copyWith(
            keys: [
              loginMessageKey,
              loginTitleKey,
            ],
          ),
        );

        final expectedContent = await File(
          'example/test_results/android/values/test_feature_a_localization.xml',
        ).readAsString();
        expect(expectedContent.tremContent(), result.tremContent());
      });

      test('generationUseCase', () async {
        final dtoTask = await generationUseCase(
          customSettingsDto,
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
          'example/test_results/android/values/test_feature_a_localization.xml',
          'example/test_results/android/values_de/test_feature_a_localization.xml',
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
  });
}
