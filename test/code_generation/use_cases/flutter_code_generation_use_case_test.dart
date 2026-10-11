import 'dart:io';

import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/exceptions/duplicate_resource_name_exception.dart';
import 'package:share_localization/code_generation/exceptions/invalid_resource_name_exception.dart';
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

    group('buildLocaleItemGetter', () {
      const snakeCaseKey = LocalizationKeyDto(
        key: 'file_size_body',
        comment: 'This is a body of the file size message.',
        arguments: [
          LocalizationKeyArgumentDto(
            name: 'file_name',
            type: LocalizationKeyDtoType.string,
          ),
          LocalizationKeyArgumentDto(
            name: 'current_size',
            type: LocalizationKeyDtoType.double,
          ),
        ],
        translations: [
          LocalizationKeyTranslationDto(
            languageKey: 'en',
            message: 'The {file_name} is {current_size} MB',
          ),
        ],
      );

      test('uses the parameter names for snake_case arguments', () {
        final result = generationUseCase.buildLocaleItemGetter(
          snakeCaseKey,
          'en',
        );

        expect(
          result,
          'String fileSizeBody(String fileName, double currentSize) => '
          r"'The $fileName is $currentSize MB';",
        );
      });

      String getterFor(String message, {bool withArgument = true}) {
        final key = LocalizationKeyDto(
          key: 'total',
          comment: 'This is a total.',
          arguments: [
            if (withArgument)
              const LocalizationKeyArgumentDto(
                name: 'size',
                type: LocalizationKeyDtoType.double,
              ),
          ],
          translations: [
            LocalizationKeyTranslationDto(languageKey: 'en', message: message),
          ],
        );
        return generationUseCase.buildLocaleItemGetter(key, 'en');
      }

      group('text right after a placeholder', () {
        // Dart reads `$sizeMB` as one identifier, so braces are required.
        test('uses braces when a letter follows', () {
          expect(
            getterFor('Total {size}MB'),
            r"String total(double size) => 'Total ${size}MB';",
          );
        });

        test('uses braces when a digit follows', () {
          expect(
            getterFor('Total {size}2'),
            r"String total(double size) => 'Total ${size}2';",
          );
        });

        test('uses braces when an underscore follows', () {
          expect(
            getterFor('Total {size}_x'),
            r"String total(double size) => 'Total ${size}_x';",
          );
        });

        test('keeps the short form when a space or punctuation follows', () {
          expect(
            getterFor('Total {size} MB'),
            r"String total(double size) => 'Total $size MB';",
          );
          expect(
            getterFor('Total {size}.'),
            r"String total(double size) => 'Total $size.';",
          );
          expect(
            getterFor('Total {size}'),
            r"String total(double size) => 'Total $size';",
          );
        });

        test('keeps the short form before a non-ASCII letter', () {
          // Dart identifiers are ASCII only, so `$sizeМБ` is `$size` + `МБ`.
          expect(
            getterFor('Total {size}МБ'),
            r"String total(double size) => 'Total $sizeМБ';",
          );
        });
      });

      // A literal `$` in the text would otherwise start an interpolation.
      group('literal dollar sign', () {
        test('is escaped next to a name', () {
          expect(
            getterFor(r'Use $HOME for {size}'),
            r"String total(double size) => 'Use \$HOME for $size';",
          );
        });

        test('is escaped before a digit and at the end', () {
          expect(
            getterFor(r'Only $5 or $', withArgument: false),
            r"String get total => 'Only \$5 or \$';",
          );
        });

        // `{value}` is a placeholder, so `${value}` is a `$` and a placeholder.
        test('is escaped before a placeholder', () {
          expect(
            getterFor(r'Cost ${value} for {size}'),
            r"String total(double size) => 'Cost \$$value for $size';",
          );
        });

        test('does not touch the placeholder substitution', () {
          expect(
            getterFor(r'$ {size}MB $'),
            r"String total(double size) => '\$ ${size}MB \$';",
          );
        });
      });

      // A backslash is escaped first, so the escapes added for `'`, newline,
      // `$` and placeholders are not doubled.
      group('literal backslash', () {
        test('is escaped in a path', () {
          expect(
            getterFor(r'Path C:\dir for {size}'),
            r"String total(double size) => 'Path C:\\dir for $size';",
          );
        });

        test('is escaped before a placeholder', () {
          expect(
            getterFor(r'\{size}MB'),
            r"String total(double size) => '\\${size}MB';",
          );
        });
      });

      // A real carriage return is a line terminator in Dart, so it must be
      // written as the two characters `\r` inside a single-quoted string.
      group('carriage return', () {
        test('is escaped in the getter', () {
          final line = getterFor('Line\r{size}');
          expect(line, r"String total(double size) => 'Line\r$size';");
          expect(line.contains('\r'), isFalse);
        });
      });
    });

    // Dart ends a `//` comment at `\n` or `\r`, so the comment and the
    // description of a `///` doc comment keep line breaks as two characters.
    group('doc comment', () {
      String commonFor(String comment, String message) {
        final key = LocalizationKeyDto(
          key: 'doc_line',
          comment: comment,
          arguments: const [],
          translations: [
            LocalizationKeyTranslationDto(languageKey: 'en', message: message),
          ],
        );
        return generationUseCase.generateCommon(
          settingsDto.toPlatformSettingsDto()!,
          localizationDto.copyWith(keys: [key]),
        );
      }

      // Every line that mentions the marker must be a `///` line.
      bool markerOnlyInDocLines(String content, String marker) {
        final lines = content.split(RegExp(r'\r\n|\n|\r'));
        final marked = lines.where((line) => line.contains(marker));
        return marked.isNotEmpty &&
            marked.every((line) => line.trimLeft().startsWith('///'));
      }

      test('escapes a carriage return in the description', () {
        final content = commonFor('Plain.', 'line1\rint injected = 1;');
        expect(content, contains(r"  /// **'line1\rint injected = 1;'**"));
        expect(content.contains('\r'), isFalse);
        expect(markerOnlyInDocLines(content, 'injected'), isTrue);
      });

      test('keeps a newline in the comment on one line', () {
        final content = commonFor('first\nint injected = 2;', 'Ok');
        expect(content, contains(r'  /// first\nint injected = 2;'));
        expect(content.contains('\r'), isFalse);
        expect(markerOnlyInDocLines(content, 'injected'), isTrue);
      });

      test('keeps a carriage return in the comment on one line', () {
        final content = commonFor('first\rint injected = 3;', 'Ok');
        expect(content, contains(r'  /// first\rint injected = 3;'));
        expect(content.contains('\r'), isFalse);
        expect(markerOnlyInDocLines(content, 'injected'), isTrue);
      });

      test('keeps a CRLF in the comment on one line', () {
        final content = commonFor('first\r\nint injected = 4;', 'Ok');
        expect(content, contains(r'  /// first\r\nint injected = 4;'));
        expect(content.contains('\r'), isFalse);
        expect(markerOnlyInDocLines(content, 'injected'), isTrue);
      });

      test('leaves a plain single-line comment and description unchanged', () {
        final content = commonFor('This is a total.', 'Total');
        expect(content, contains('  /// This is a total.\n'));
        expect(content, contains("  /// **'Total'**"));
      });
    });

    group('flutterDocCommentEscape', () {
      test('escapes a CRLF pair as two escapes in order', () {
        expect('a\r\nb'.flutterDocCommentEscape(), r'a\r\nb');
      });

      test('escapes a lone carriage return', () {
        expect('a\rb'.flutterDocCommentEscape(), r'a\rb');
      });

      test('escapes a lone newline', () {
        expect('a\nb'.flutterDocCommentEscape(), r'a\nb');
      });

      test('keeps single-line text unchanged', () {
        expect('Total size'.flutterDocCommentEscape(), 'Total size');
      });
    });

    group('flutterEscape', () {
      test('escapes a backslash', () {
        expect(r'C:\dir'.flutterEscape(), r'C:\\dir');
      });

      test('keeps a literal backslash-n apart from a real newline', () {
        expect(r'\n'.flutterEscape(), r'\\n');
        expect('\n'.flutterEscape(), r'\n');
      });

      test('escapes a backslash before a quote', () {
        expect(r"\'".flutterEscape(), r"\\\'");
      });

      test('escapes a backslash before a dollar sign', () {
        expect(r'\$'.flutterEscape(), r'\\\$');
      });

      test('escapes a backslash before a placeholder', () {
        expect(r'\{name}'.flutterEscape(), r'\\$name');
      });

      test('escapes a carriage return', () {
        expect('\r'.flutterEscape(), r'\r');
      });

      test('escapes a CRLF pair as two escapes', () {
        expect('\r\n'.flutterEscape(), r'\r\n');
      });

      test('keeps a literal backslash-r apart from a real carriage return', () {
        expect(r'a\rb'.flutterEscape(), r'a\\rb');
        expect('a\rb'.flutterEscape(), r'a\rb');
      });

      test('escapes a carriage return next to a placeholder', () {
        expect('{name}\r'.flutterEscape(), r'$name\r');
      });

      test('escapes a carriage return before a quote', () {
        expect("\r'".flutterEscape(), r"\r\'");
      });

      test('returns an empty string for empty input', () {
        expect(''.flutterEscape(), '');
      });

      test('escapes a lone backslash', () {
        // A single backslash cannot be a raw string literal.
        expect(String.fromCharCode(0x5C).flutterEscape(), r'\\');
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
            platform: ResourcePlatform.flutter,
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
            platform: ResourcePlatform.flutter,
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
          localizationDto.copyWith(
            keys: [cyrillicKey, dashKey, underscoreKey],
          ),
        );

        expect(dtoTask.failed, isTrue);
        expect(
          dtoTask.exception,
          isA<CompositeException>().having((e) => e.exceptions, 'exceptions', [
            const InvalidResourceNameException(
              platform: ResourcePlatform.flutter,
              key: 'ключ',
              name: '',
              bundleName: 'test_feature_A.json',
            ),
            const DuplicateResourceNameException(
              platform: ResourcePlatform.flutter,
              key: 'my_key',
              otherKey: 'my-key',
              name: 'myKey',
              bundleName: 'test_feature_A.json',
            ),
          ]),
        );
        expect(virtualFiles, isEmpty);
      });
    });
  });
}
