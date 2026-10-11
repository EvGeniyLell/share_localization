import 'dart:io';

import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/use_cases/android/android_code_generation_use_case.dart';
import 'package:test/test.dart';

import '../../common/mocks.dart';
import '../../helpers/mock_file_service_helper.dart';
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

    setUpMockFileService(fileService, virtualFiles);
  });

  group('FlutterCodeGenerationUseCase', () {
    late SettingsDto customSettingsDto;

    group('useCamelCase: true', () {
      setUp(() {
        customSettingsDto = settingsDto.copyWith(
          android: const AndroidOptionsDto(
            useCamelCase: true,
            useFilePrefixForKeys: true,
            destinationFolder: 'example/test_results/android/camel_case/values',
          ),
        );
      });

      test('generateXml', () async {
        final result = generationUseCase.generateXml(
          customSettingsDto.toPlatformSettingsDto()!,
          settingsEnLanguageDto,
          localizationDto.copyWith(keys: [loginMessageKey, loginTitleKey]),
        );

        final expectedContent = await File(
          'example/test_results/android/camel_case/values/test_feature_a.xml',
        ).readAsString();
        expect(result.tremContent(), expectedContent.tremContent());
      });

      test('generationUseCase', () async {
        final dtoTask = await generationUseCase(
          customSettingsDto,
          localizationDto.copyWith(keys: [loginMessageKey, loginTitleKey]),
        );
        expect(dtoTask.succeeded, true);
        expect(virtualFiles.length, 2);
        expect(virtualFiles.map((f) => f.path), [
          'example/test_results/android/camel_case/values/test_feature_a.xml',
          'example/test_results/android/camel_case/values-de/test_feature_a.xml',
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
            useFilePrefixForKeys: true,
            destinationFolder: 'example/test_results/android/values',
          ),
        );
      });

      test('generateXml', () async {
        final result = generationUseCase.generateXml(
          customSettingsDto.toPlatformSettingsDto()!,
          settingsEnLanguageDto,
          localizationDto.copyWith(keys: [loginMessageKey, loginTitleKey]),
        );

        final expectedContent = await File(
          'example/test_results/android/values/test_feature_a.xml',
        ).readAsString();
        expect(result.tremContent(), expectedContent.tremContent());
      });

      test('generationUseCase', () async {
        final dtoTask = await generationUseCase(
          customSettingsDto,
          localizationDto.copyWith(keys: [loginMessageKey, loginTitleKey]),
        );
        expect(dtoTask.succeeded, true);
        expect(virtualFiles.length, 2);
        expect(virtualFiles.map((f) => f.path), [
          'example/test_results/android/values/test_feature_a.xml',
          'example/test_results/android/values-de/test_feature_a.xml',
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

    test(
      'failed with missingAndroidSettings when android block is absent',
      () async {
        final dtoTask = await generationUseCase(
          settingsDtoWithoutAndroid,
          localizationDto,
        );

        expect(dtoTask.failed, true);
        expect(
          dtoTask.exception,
          const BuildLocalizationException.missingAndroidSettings(),
        );
        expect(virtualFiles, isEmpty);
      },
    );

    group('androidTranslationEscape', () {
      // Each row: input -> expected output. Android XML must not contain a
      // bare `&` or `<`, and a leading `@` or `?` is read as a reference.
      final cases = <String, String>{
        'Tom & Jerry': 'Tom &amp; Jerry',
        'a & b < c': 'a &amp; b &lt; c',
        '&lt;': '&amp;lt;',
        '@home': r'\@home',
        '?attr': r'\?attr',
        '@': r'\@',
        '?': r'\?',
        'mail@host?x': 'mail@host?x',
        '': '',
        "it's <b>": r"it\'s &lt;b>",
      };
      for (final entry in cases.entries) {
        test('escapes ${entry.key.isEmpty ? '<empty>' : entry.key}', () {
          expect(entry.key.androidTranslationEscape(), entry.value);
        });
      }
    });

    group('buildLocaleItemGetter', () {
      test('produces a valid string element for an ampersand', () {
        final result = generationUseCase.buildLocaleItemGetter(
          settingsDto.toPlatformSettingsDto()!,
          '',
          loginTitleKey.copyWith(
            key: 'tom',
            translations: const [
              LocalizationKeyTranslationDto(
                languageKey: 'en',
                message: 'Tom & Jerry',
              ),
            ],
          ),
          'en',
        );

        expect(result, contains('>Tom &amp; Jerry</string>'));
      });

      test('keeps placeholders working next to a leading ampersand', () {
        final result = generationUseCase.buildLocaleItemGetter(
          settingsDto.toPlatformSettingsDto()!,
          '',
          loginMessageKey.copyWith(
            key: 'greet',
            arguments: const [
              LocalizationKeyArgumentDto(
                name: 'name',
                type: LocalizationKeyDtoType.string,
              ),
            ],
            translations: const [
              LocalizationKeyTranslationDto(
                languageKey: 'en',
                message: '@{name} & more',
              ),
            ],
          ),
          'en',
        );

        expect(result, contains(r'>\@%1$s &amp; more</string>'));
      });
    });

    group('androidArgumentsEscape', () {
      const fileName = LocalizationKeyArgumentDto(
        name: 'file_name',
        type: LocalizationKeyDtoType.string,
      );
      const size = LocalizationKeyArgumentDto(
        name: 'size',
        type: LocalizationKeyDtoType.double,
      );
      const count = LocalizationKeyArgumentDto(
        name: 'count',
        type: LocalizationKeyDtoType.int,
      );

      test('keeps declared positions and types', () {
        final result = '{file_name} is {size}'.androidArgumentsEscape([
          fileName,
          size,
        ]);

        expect(result, r'%1$s is %2$f');
      });

      test('uses declared position and type when order differs', () {
        final result = '{size} for {file_name}'.androidArgumentsEscape([
          fileName,
          size,
        ]);

        expect(result, r'%2$f for %1$s');
      });

      test('reuses the same position for a repeated placeholder', () {
        final result = '{count} of {count}'.androidArgumentsEscape([count]);

        expect(result, r'%1$d of %1$d');
      });

      test('leaves an unknown placeholder untouched', () {
        final result = '{nope} and {size}'.androidArgumentsEscape([
          fileName,
          size,
        ]);

        expect(result, r'{nope} and %2$f');
      });

      // A string with arguments is a format string, so `%` must be `%%`.
      test('escapes a literal percent when the key has arguments', () {
        final result = '100% of {size}'.androidArgumentsEscape([size]);

        expect(result, r'100%% of %1$f');
      });

      test('escapes a percent next to a placeholder', () {
        final result = 'Save {size}%'.androidArgumentsEscape([size]);

        expect(result, r'Save %1$f%%');
      });

      // Without arguments the string is read with getString(id), which does
      // not format, so `%%` would be shown twice.
      test('keeps a literal percent when the key has no arguments', () {
        final result = '100% complete'.androidArgumentsEscape([]);

        expect(result, '100% complete');
      });
    });

    test('generationUseCase with int and double arguments', () async {
      final dtoTask = await generationUseCase(
        settingsDto.copyWith(
          android: const AndroidOptionsDto(
            useCamelCase: false,
            useFilePrefixForKeys: true,
            destinationFolder: 'example/test_results/android/values',
          ),
        ),
        numericLocalizationDto,
      );

      expect(dtoTask.succeeded, true);
      expect(virtualFiles.map((f) => f.path), [
        'example/test_results/android/values/test_numbers.xml',
        'example/test_results/android/values-de/test_numbers.xml',
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
