import 'dart:convert';
import 'dart:io';

import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/use_cases/ios/ios_code_generation_use_case.dart';
import 'package:test/test.dart';

import '../../common/mocks.dart';
import '../../helpers/mock_file_service_helper.dart';
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

    setUpMockFileService(fileService, virtualFiles);
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

    test('iosMessage escapes literal percent when key has arguments', () {
      const name = LocalizationKeyArgumentDto(
        name: 'name',
        type: LocalizationKeyDtoType.string,
      );
      const count = LocalizationKeyArgumentDto(
        name: 'n',
        type: LocalizationKeyDtoType.int,
      );
      const sure = LocalizationKeyTranslationDto(
        languageKey: 'en',
        message: '100% sure, {name}',
      );
      const done = LocalizationKeyTranslationDto(
        languageKey: 'en',
        message: '{n}% done',
      );
      const alreadyEscaped = LocalizationKeyTranslationDto(
        languageKey: 'en',
        message: '50%% already, {name}',
      );
      expect(sure.iosMessage([name]), r'100%% sure, %1$@');
      expect(done.iosMessage([count]), r'%1$lld%% done');
      expect(alreadyEscaped.iosMessage([name]), r'50%%%% already, %1$@');
    });

    test('iosMessage keeps literal percent when key has no arguments', () {
      const translation = LocalizationKeyTranslationDto(
        languageKey: 'en',
        message: '100% sure',
      );
      expect(translation.iosMessage(const []), '100% sure');
    });

    test('iosMessage keeps placeholder-only message unchanged', () {
      const name = LocalizationKeyArgumentDto(
        name: 'name',
        type: LocalizationKeyDtoType.string,
      );
      const translation = LocalizationKeyTranslationDto(
        languageKey: 'en',
        message: '{name}',
      );
      expect(translation.iosMessage([name]), r'%1$@');
    });

    test('xcstrings value escapes literal percent for key with arguments', () {
      const name = LocalizationKeyArgumentDto(
        name: 'name',
        type: LocalizationKeyDtoType.string,
      );
      const translation = LocalizationKeyTranslationDto(
        languageKey: 'en',
        message: '100% sure, {name}',
      );
      const key = LocalizationKeyDto(
        key: 'sure_message',
        comment: 'Certainty message.',
        arguments: [name],
        translations: [translation],
      );
      final result = BuildIosLocalizationUseCaseXCStrings(
        generationUseCase,
      ).buildXCStringsItemTranslation(key, translation);
      expect(result, contains(r'"value" : "100%% sure, %1$@"'));
    });

    test('xcstrings value escapes literal backslash', () {
      const name = LocalizationKeyArgumentDto(
        name: 'name',
        type: LocalizationKeyDtoType.string,
      );
      const translation = LocalizationKeyTranslationDto(
        languageKey: 'en',
        message: r'C:\dir for {name}',
      );
      const key = LocalizationKeyDto(
        key: 'path_message',
        comment: 'Path message.',
        arguments: [name],
        translations: [translation],
      );
      final result = BuildIosLocalizationUseCaseXCStrings(
        generationUseCase,
      ).buildXCStringsItemTranslation(key, translation);
      expect(result, contains(r'"value" : "C:\\dir for %1$@"'));
    });

    test('iosXCSTranslationEscape table', () {
      final cases = <String, String>{
        r'C:\dir': r'C:\\dir',
        r'\n': r'\\n',
        '\n': r'\n',
        r'\"': r'\\\"',
        String.fromCharCode(0x5C): r'\\',
        '\t': r'\t',
        '\r': r'\r',
        '"': r'\"',
        '': '',
        r'a\b"c': r'a\\b\"c',
      };
      for (final entry in cases.entries) {
        expect(
          entry.key.iosXCSTranslationEscape(),
          entry.value,
          reason: 'input: ${entry.key}',
        );
      }
    });

    test(
      'iosXCSTranslationEscape round-trips through JSON string decoding',
      () {
        const message = 'a\\b "q"\tt\rr\nn C:\\dir\\n';
        final escaped = message.iosXCSTranslationEscape();
        expect(jsonDecode('"$escaped"'), message);
      },
    );

    test('iosKey', () {
      final keys = [loginMessageKey, loginTitleKey];
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
        localizationDto.copyWith(keys: [loginMessageKey, loginTitleKey]),
      );

      final expectedContent = await File(
        'example/test_results/ios/TestFeatureALocalization.xcstrings',
      ).readAsString();
      expect(result.tremContent(), expectedContent.tremContent());
    });

    test('generateSwift', () async {
      final result = generationUseCase.generateSwift(
        settingsDto.toPlatformSettingsDto()!,
        localizationDto.copyWith(keys: [loginMessageKey, loginTitleKey]),
      );

      final expectedContent = await File(
        'example/test_results/ios/TestFeatureALocalization.swift',
      ).readAsString();
      expect(result.tremContent(), expectedContent.tremContent());
    });

    test('generationUseCase', () async {
      final dtoTask = await generationUseCase(
        settingsDto,
        localizationDto.copyWith(keys: [loginMessageKey, loginTitleKey]),
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

    test('failed with missingIosSettings when ios block is absent', () async {
      final dtoTask = await generationUseCase(
        settingsDtoWithoutIos,
        localizationDto,
      );

      expect(dtoTask.failed, true);
      expect(
        dtoTask.exception,
        const BuildLocalizationException.missingIosSettings(),
      );
      expect(virtualFiles, isEmpty);
    });

    test('generationUseCase with int and double arguments', () async {
      final dtoTask = await generationUseCase(
        settingsDto,
        numericLocalizationDto,
      );

      expect(dtoTask.succeeded, true);
      expect(virtualFiles.map((f) => f.path), [
        'example/test_results/ios/TestNumbersLocalization.xcstrings',
        'example/test_results/ios/TestNumbersLocalization.swift',
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
