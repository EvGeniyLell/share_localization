import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:share_localization/code_generation/use_cases/ios/ios_code_generation_use_case.dart';
import 'package:test/test.dart';

import '../../common/mocks.dart';
import '../../localizations/mocks.dart';
import '../../settings/mocks.dart';

void main() {
  // Printer.debug = true;

  late List<InvocationCreateFile> virtualFiles;
  late FileService fileService;
  late IosCodeGenerationUseCase generationUseCase;

  setUp(() {
    virtualFiles = [];
    fileService = MockFileService();
    generationUseCase = IosCodeGenerationUseCase(fileService);

    when(() {
      return fileService.createFile(
        path: any(named: 'path'),
        content: any(named: 'content'),
      );
    }).thenAnswer((invocation) async {
      virtualFiles.add(InvocationCreateFile(invocation));
    });
  });

  group('IosCodeGenerationUseCase', () {
    test('iosMessage', () {
      for (final translation in loginMessageKeyLocalizations) {
        final result = translation.iosMessage(loginMessageKeyArguments);
        expect(
          result,
          anyOf(
            r'Hi %1$@, your password is %2$@',
            r'Heilegh %1$@, dein passdahwordther ist %2$@',
          ),
        );
      }
    });

    test('iosKey', () {
      final keys = [
        loginMessageKey,
        loginTitleKey,
      ];
      for (final key in keys) {
        final result = key.iosXCStringKey();
        expect(result, anyOf('loginMessage%@%@', 'loginTitle'));
      }
    });

    // TODO(evg): need to add expected part
    // test('buildXCStringsItem', () async {
    //   final keys = [
    //     loginMessageKey,
    //     loginTitleKey,
    //   ];
    //   for (final key in keys) {
    //     final result = generationUseCase.buildXCStringsItem(key);
    //     print(result);
    //     expect(result, anyOf('login_message%@%@', 'login_title'));
    //   }
    // });

    test('generateXCStrings', () async {
      final result = generationUseCase.generateXCStrings(
        settingsDto.toPlatformSettingsDto()!,
        localizationDto.copyWith(
          keys: [
            loginMessageKey,
            loginTitleKey,
          ],
        ),
      );

      final expectedContent = await File(
        'example/test_results/ios/TestFeatureALocalization.xcstrings',
      ).readAsString();
      expect(expectedContent.tremContent(), result.tremContent());
    });

    test('generateSwift', () async {
      final result = generationUseCase.generateSwift(
        settingsDto.toPlatformSettingsDto()!,
        localizationDto.copyWith(
          keys: [
            loginMessageKey,
            loginTitleKey,
          ],
        ),
      );

      final expectedContent = await File(
        'example/test_results/ios/TestFeatureALocalization.swift',
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
        'example/test_results/ios/TestFeatureALocalization.xcstrings',
        'example/test_results/ios/TestFeatureALocalization.swift',
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
