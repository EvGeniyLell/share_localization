import 'dart:io';

import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/use_cases/flutter/flutter_code_generation_use_case.dart';
import 'package:test/test.dart';

import '../../common/mocks.dart';
import '../../helpers/mock_file_service_helper.dart';
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

    setUpMockFileService(fileService, virtualFiles);
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
      expect(result.tremContent(), expectedContent.tremContent());
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
      expect(result.tremContent(), expectedContent.tremContent());
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

    test(
      'failed with missingFlutterSettings when flutter block is absent',
      () async {
        final dtoTask = await generationUseCase(
          settingsDtoWithoutFlutter,
          localizationDto,
        );

        expect(dtoTask.failed, true);
        expect(
          dtoTask.exception,
          const BuildLocalizationException.missingFlutterSettings(),
        );
        expect(virtualFiles, isEmpty);
      },
    );

    test('generationUseCase with int and double arguments', () async {
      final dtoTask = await generationUseCase(
        settingsDto,
        numericLocalizationDto,
      );

      expect(dtoTask.succeeded, true);
      expect(virtualFiles.map((f) => f.path), [
        'example/test_results/flutter/test_numbers_localization.dart',
        'example/test_results/flutter/test_numbers_localization_en.dart',
        'example/test_results/flutter/test_numbers_localization_de.dart',
      ]);
      for (final file in virtualFiles) {
        final expectedContent = await File(file.path).readAsString();
        expect(
          file.content.tremContent(),
          expectedContent.tremContent(),
          reason: file.toString(),
        );
      }
    });
  });
}
