import 'dart:convert';
import 'dart:io';

import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/exceptions/duplicate_resource_name_exception.dart';
import 'package:share_localization/code_generation/exceptions/invalid_resource_name_exception.dart';
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

    test('iosXCSTranslationEscape escapes other control characters', () {
      final cases = <String, String>{
        '\u0000': r'\u0000',
        '\u0001': r'\u0001',
        '\u0008': r'\u0008',
        '\u000c': r'\u000c',
        '\u001f': r'\u001f',
        '\u007f': '\u007f',
        '\\\u0001': r'\\\u0001',
        '\n\t\r': r'\n\t\r',
      };
      for (final entry in cases.entries) {
        expect(
          entry.key.iosXCSTranslationEscape(),
          entry.value,
          reason: 'input: ${entry.key.codeUnits}',
        );
      }
    });

    test('iosXCSTranslationEscape round-trips every control character', () {
      final controls = String.fromCharCodes([
        for (var i = 0; i <= 0x1f; i++) i,
      ]);
      final message = '$controls\u007f "q" \\ end';
      final escaped = message.iosXCSTranslationEscape();
      expect(jsonDecode('"$escaped"'), message);
    });

    group('control characters (N11)', () {
      test('generateXCStrings escapes control characters in value and '
          'comment and round-trips through JSON', () {
        const message = 'bell\u0007 nul\u0000 ff\u000c bs\u0008 us\u001f';
        const comment = 'c\u0001 tab\t nl\n del\u007f';
        const key = LocalizationKeyDto(
          key: 'control_message',
          comment: comment,
          arguments: [],
          translations: [
            LocalizationKeyTranslationDto(languageKey: 'en', message: message),
          ],
        );
        final result = generationUseCase.generateXCStrings(
          settingsDto.toPlatformSettingsDto()!,
          localizationDto.copyWith(keys: [key]),
        );

        final decoded = jsonDecode(result) as Map<String, dynamic>;
        final strings = decoded['strings'] as Map<String, dynamic>;
        final item = strings['controlMessage'] as Map<String, dynamic>;
        expect(item['comment'], comment);
        final localizations = item['localizations'] as Map<String, dynamic>;
        final en = localizations['en'] as Map<String, dynamic>;
        final unit = en['stringUnit'] as Map<String, dynamic>;
        expect(unit['value'], message);
      });
    });

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

    group('comment escaping (N9)', () {
      IosSettingsDto iosSettings() => settingsDto.toPlatformSettingsDto()!;

      LocalizationKeyDto keyWithComment(String comment) {
        return LocalizationKeyDto(
          key: 'commented_message',
          comment: comment,
          arguments: const [],
          translations: const [
            LocalizationKeyTranslationDto(languageKey: 'en', message: 'Hello'),
          ],
        );
      }

      test('xcstrings comment with quote, backslash, newline, tab and CR '
          'is escaped and round-trips through JSON', () {
        const comment = 'say "hi" \\ x\nnext\tt\rcr';
        final key = keyWithComment(comment);
        final item = BuildIosLocalizationUseCaseXCStrings(
          generationUseCase,
        ).buildXCStringsItem(key);

        expect(item, contains(r'"comment" : "say \"hi\" \\ x\nnext\tt\rcr",'));
        final decoded = jsonDecode('{$item}') as Map<String, dynamic>;
        final value = decoded['commentedMessage'] as Map<String, dynamic>;
        expect(value['comment'], comment);
      });

      test('xcstrings plain and empty comments are unchanged', () {
        expect(
          BuildIosLocalizationUseCaseXCStrings(
            generationUseCase,
          ).buildXCStringsItem(keyWithComment('Plain comment.')),
          contains('"comment" : "Plain comment.",'),
        );
        expect(
          BuildIosLocalizationUseCaseXCStrings(
            generationUseCase,
          ).buildXCStringsItem(keyWithComment('')),
          contains('"comment" : "",'),
        );
      });

      test('swift comment with real newline stays inside the doc comment', () {
        final language = iosSettings().languages.first;
        final key = keyWithComment('line one\nline two');
        final result = BuildIosLocalizationUseCaseSwift(
          generationUseCase,
        ).buildXCStringsItemTranslation(language, key, key.translations.first);

        expect(result, contains(r'  /// line one\nline two'));
        final lines = result.split('\n').map((line) => line.trim());
        expect(lines, isNot(contains('line two')));
      });

      test('swift comment with real CR has no raw CR character', () {
        final language = iosSettings().languages.first;
        final key = keyWithComment('a\rb');
        final result = BuildIosLocalizationUseCaseSwift(
          generationUseCase,
        ).buildXCStringsItemTranslation(language, key, key.translations.first);

        expect(result, contains(r'  /// a\rb'));
        expect(result.contains('\r'), isFalse);
      });

      test('swift plain and empty comments are unchanged', () {
        final language = iosSettings().languages.first;
        final plainKey = keyWithComment('Plain comment.');
        final plain = BuildIosLocalizationUseCaseSwift(generationUseCase)
            .buildXCStringsItemTranslation(
              language,
              plainKey,
              plainKey.translations.first,
            );
        expect(plain, startsWith('  /// Plain comment.\n'));

        final emptyKey = keyWithComment('');
        final empty = BuildIosLocalizationUseCaseSwift(generationUseCase)
            .buildXCStringsItemTranslation(
              language,
              emptyKey,
              emptyKey.translations.first,
            );
        expect(empty.split('\n').first, '  /// ');
      });
    });

    group('invalid or duplicate resource names', () {
      final dashKey = loginTitleKey.copyWith(key: 'my-key');
      final underscoreKey = loginTitleKey.copyWith(key: 'my_key');
      final cyrillicKey = loginTitleKey.copyWith(key: 'ключ');

      test('fails for duplicate names and writes nothing', () async {
        final dtoTask = await generationUseCase(
          settingsDto,
          localizationDto.copyWith(keys: [dashKey, underscoreKey]),
        );

        expect(dtoTask.failed, isTrue);
        expect(
          dtoTask.exception,
          const DuplicateResourceNameException(
            platform: ResourcePlatform.ios,
            key: 'my_key',
            otherKey: 'my-key',
            name: 'myKey',
            bundleName: 'test_feature_A.json',
          ),
        );
        expect(virtualFiles, isEmpty);
      });

      test('fails for a key with no ASCII letters, writes nothing', () async {
        final dtoTask = await generationUseCase(
          settingsDto,
          localizationDto.copyWith(keys: [cyrillicKey]),
        );

        expect(dtoTask.failed, isTrue);
        expect(
          dtoTask.exception,
          const InvalidResourceNameException(
            platform: ResourcePlatform.ios,
            key: 'ключ',
            name: '',
            bundleName: 'test_feature_A.json',
          ),
        );
        expect(virtualFiles, isEmpty);
      });

      test('reports an invalid and a duplicate key in key order', () async {
        final dtoTask = await generationUseCase(
          settingsDto,
          localizationDto.copyWith(keys: [cyrillicKey, dashKey, underscoreKey]),
        );

        expect(dtoTask.failed, isTrue);
        expect(
          dtoTask.exception,
          isA<CompositeException>().having((e) => e.exceptions, 'exceptions', [
            const InvalidResourceNameException(
              platform: ResourcePlatform.ios,
              key: 'ключ',
              name: '',
              bundleName: 'test_feature_A.json',
            ),
            const DuplicateResourceNameException(
              platform: ResourcePlatform.ios,
              key: 'my_key',
              otherKey: 'my-key',
              name: 'myKey',
              bundleName: 'test_feature_A.json',
            ),
          ]),
        );
        expect(virtualFiles, isEmpty);
      });

      group('same base, different arguments (identity: base + types)', () {
        const stringArg = LocalizationKeyArgumentDto(
          name: 'name',
          type: LocalizationKeyDtoType.string,
        );
        const otherStringArg = LocalizationKeyArgumentDto(
          name: 'user',
          type: LocalizationKeyDtoType.string,
        );
        const intArg = LocalizationKeyArgumentDto(
          name: 'count',
          type: LocalizationKeyDtoType.int,
        );
        final plainFoo = loginTitleKey.copyWith(key: 'foo');
        final fooString = loginTitleKey.copyWith(
          key: 'foo',
          arguments: [stringArg],
        );
        final fooInt = loginTitleKey.copyWith(key: 'foo', arguments: [intArg]);
        final fooStringInt = loginTitleKey.copyWith(
          key: 'foo',
          arguments: [stringArg, intArg],
        );

        String swiftOf(List<InvocationCreateFile> files) {
          return files.singleWhere((f) => f.path.endsWith('.swift')).content;
        }

        test('a no-arg key and a String-arg key both generate', () async {
          final dtoTask = await generationUseCase(
            settingsDto,
            localizationDto.copyWith(keys: [plainFoo, fooString]),
          );

          expect(dtoTask.failed, isFalse);
          expect(virtualFiles, hasLength(2));
          final swift = swiftOf(virtualFiles);
          expect(swift, contains('static var foo'));
          expect(swift, contains('static func foo(_'));
        });

        test('String and Int args with one base both generate', () async {
          final dtoTask = await generationUseCase(
            settingsDto,
            localizationDto.copyWith(keys: [fooString, fooInt]),
          );

          expect(dtoTask.failed, isFalse);
          expect(virtualFiles, hasLength(2));
          expect(swiftOf(virtualFiles), contains('static func foo(_'));
        });

        test('one String arg and two args, one base, both generate', () async {
          final dtoTask = await generationUseCase(
            settingsDto,
            localizationDto.copyWith(keys: [fooString, fooStringInt]),
          );

          expect(dtoTask.failed, isFalse);
          expect(virtualFiles, hasLength(2));
          expect(swiftOf(virtualFiles), contains('static func foo(_'));
        });

        test('same camelCase and types, other arg names: duplicate', () async {
          final dtoTask = await generationUseCase(
            settingsDto,
            localizationDto.copyWith(
              keys: [
                fooString.copyWith(key: 'my-key'),
                fooString.copyWith(key: 'my_key', arguments: [otherStringArg]),
              ],
            ),
          );

          expect(dtoTask.failed, isTrue);
          expect(
            dtoTask.exception,
            const DuplicateResourceNameException(
              platform: ResourcePlatform.ios,
              key: 'my_key',
              otherKey: 'my-key',
              name: 'myKey',
              bundleName: 'test_feature_A.json',
            ),
          );
          expect(virtualFiles, isEmpty);
        });
      });

      test('valid keys still write both files', () async {
        final dtoTask = await generationUseCase(
          settingsDto,
          localizationDto.copyWith(keys: [loginMessageKey, loginTitleKey]),
        );

        expect(dtoTask.failed, isFalse);
        expect(virtualFiles, hasLength(2));
      });
    });
  });
}
