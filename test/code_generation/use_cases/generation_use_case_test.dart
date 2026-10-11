import 'dart:convert';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:share_localization/code_generation/build_report.dart';
import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/exceptions/duplicate_resource_name_exception.dart';
import 'package:share_localization/code_generation/exceptions/invalid_resource_name_exception.dart';
import 'package:share_localization/code_generation/use_cases/batch_code_generation_use_case.dart';
import 'package:share_localization/code_generation/use_cases/code_generation_use_case.dart';
import 'package:share_localization/code_generation/use_cases/flutter/flutter_code_generation_use_case.dart';
import 'package:share_localization/localizations/localizations.dart';
import 'package:test/test.dart';

import '../../common/mocks.dart';
import '../../helpers/mock_file_service_helper.dart';
import '../../localizations/mocks.dart';
import '../../settings/mocks.dart';

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

    setUpMockFileService(fileService, virtualFiles);

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
      expect(result.data, isA<BuildReport>());
      expect(result.data.errors, isEmpty);
      expect(virtualFiles.length, 14);
      expect(virtualFiles.map((f) => f.path), [
        'example/results/flutter/feature_a_localization.dart',
        'example/results/flutter/feature_a_localization_en.dart',
        'example/results/flutter/feature_a_localization_ua.dart',
        'example/results/ios/FeatureALocalization.xcstrings',
        'example/results/ios/FeatureALocalization.swift',
        'example/results/android/values/feature_a.xml',
        'example/results/android/values-ua/feature_a.xml',
        'example/results/flutter/general_localization.dart',
        'example/results/flutter/general_localization_en.dart',
        'example/results/flutter/general_localization_ua.dart',
        'example/results/ios/GeneralLocalization.xcstrings',
        'example/results/ios/GeneralLocalization.swift',
        'example/results/android/values/general.xml',
        'example/results/android/values-ua/general.xml',
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

    test('failed when the settings file does not exist', () async {
      final result = await generationUseCase('example/does_not_exist.json');

      expect(result.failed, isTrue);
      expect(result.exception, isA<SettingsNotFoundException>());
      expect(virtualFiles, isEmpty);
    });

    test('reports a failed builder and still runs the others', () async {
      final useCase = BatchCodeGenerationUseCase(
        generationUseCase.settingsLoader,
        generationUseCase.localizationLoader,
        generationUseCase.verificationLocalization,
        [
          _FailingCodeGenerationUseCase(fileService),
          FlutterCodeGenerationUseCase(fileService),
        ],
        fileService,
      );

      final result = await useCase('example/settings.json');

      // A failing builder is reported, it does not fail the whole task.
      expect(result.succeeded, isTrue);
      expect(result.data.hasErrors, isTrue);
      // One failure per localization (feature_a and general).
      expect(result.data.errors, hasLength(2));
      for (final error in result.data.errors) {
        expect(error, isA<UnexpectedException>());
        expect(error.toString(), contains('builder failed'));
      }
      // The builder after the failing one still wrote its files.
      expect(virtualFiles, hasLength(6));
      for (final file in virtualFiles) {
        expect(file.path, startsWith('example/results/flutter/'));
      }
    });

    test('warns about an unused argument and still writes files', () async {
      final tempDir = Directory.systemTemp.createTempSync('share_loc_r1_');
      try {
        final settingsFile = File('${tempDir.path}/settings.json')
          ..writeAsStringSync(File('example/settings.json').readAsStringSync());
        // "unused" is declared but never used in the messages, so the
        // verification reports it once per translation (en and ua).
        final bundleFile = File('${tempDir.path}/greeting.json')
          ..writeAsStringSync(
            jsonEncode({
              'languages': ['en', 'ua'],
              'keys': {
                'greeting': {
                  'comment': 'A greeting.',
                  'arguments': [
                    {'name': 'name', 'type': 'String'},
                    {'name': 'unused', 'type': 'String'},
                  ],
                  'localizations': {
                    'en': 'Hello {name}',
                    'ua': 'Привіт {name}',
                  },
                },
              },
            }),
          );
        when(() {
          return fileService.getFilesInDirectory(
            path: any(named: 'path'),
            extension: any(named: 'extension'),
          );
        }).thenAnswer((_) async => [bundleFile]);

        final result = await generationUseCase(settingsFile.path);

        expect(result.succeeded, isTrue);
        final report = result.data;
        expect(report.hasErrors, isFalse);
        expect(report.warnings, hasLength(2));
        expect(
          report.warnings,
          everyElement(
            isA<VerificationLocalizationExtraArgumentException>().having(
              (e) => e.argument,
              'argument',
              'unused',
            ),
          ),
        );
        expect(virtualFiles, isNotEmpty);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('reports the missing ios block once for two bundles', () async {
      final tempDir = Directory.systemTemp.createTempSync('share_loc_r2_');
      try {
        // Same settings as the example, without the "ios" block.
        final json =
            jsonDecode(File('example/settings.json').readAsStringSync())
                  as Map<String, dynamic>
              ..remove('ios');
        final settingsFile = File('${tempDir.path}/settings.json')
          ..writeAsStringSync(jsonEncode(json));

        final result = await generationUseCase(settingsFile.path);

        expect(result.succeeded, isTrue);
        final report = result.data;
        expect(report.hasErrors, isFalse);
        final iosWarnings = report.warnings.where(
          (w) =>
              w is BuildLocalizationException &&
              w.type == BuildLocalizationExceptionType.missingIosSettings,
        );
        expect(iosWarnings, hasLength(1));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('reports every invalid bundle in file order', () async {
      final tempDir = Directory.systemTemp.createTempSync('share_loc_r3_');
      try {
        final settingsFile = File('${tempDir.path}/settings.json')
          ..writeAsStringSync(File('example/settings.json').readAsStringSync());
        final firstBundle = File('${tempDir.path}/a_broken.json')
          ..writeAsStringSync('{ not json');
        final secondBundle = File('${tempDir.path}/b_broken.json')
          ..writeAsStringSync('{ not json');
        when(() {
          return fileService.getFilesInDirectory(
            path: any(named: 'path'),
            extension: any(named: 'extension'),
          );
        }).thenAnswer((_) async => [firstBundle, secondBundle]);

        final result = await generationUseCase(settingsFile.path);

        expect(result.failed, isTrue);
        expect(
          result.exception,
          isA<CompositeException>().having((e) => e.exceptions, 'exceptions', [
            isA<InvalidJsonException>().having(
              (e) => e.path,
              'path',
              firstBundle.path,
            ),
            isA<InvalidJsonException>().having(
              (e) => e.path,
              'path',
              secondBundle.path,
            ),
          ]),
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('reports every failed verification in file order', () async {
      final tempDir = Directory.systemTemp.createTempSync('share_loc_r4_');
      try {
        final settingsFile = File('${tempDir.path}/settings.json')
          ..writeAsStringSync(File('example/settings.json').readAsStringSync());
        // Both bundles miss the "ua" language required by the settings.
        final firstBundle = File('${tempDir.path}/a_partial.json')
          ..writeAsStringSync(
            jsonEncode({
              'languages': ['en'],
              'keys': {},
            }),
          );
        final secondBundle = File('${tempDir.path}/b_partial.json')
          ..writeAsStringSync(
            jsonEncode({
              'languages': ['en'],
              'keys': {},
            }),
          );
        when(() {
          return fileService.getFilesInDirectory(
            path: any(named: 'path'),
            extension: any(named: 'extension'),
          );
        }).thenAnswer((_) async => [firstBundle, secondBundle]);

        final result = await generationUseCase(settingsFile.path);

        expect(result.failed, isTrue);
        expect(
          result.exception,
          isA<CompositeException>().having((e) => e.exceptions, 'exceptions', [
            isA<VerificationLocalizationMissingLanguageException>().having(
              (e) => e.sourceName,
              'sourceName',
              'a_partial.json',
            ),
            isA<VerificationLocalizationMissingLanguageException>().having(
              (e) => e.sourceName,
              'sourceName',
              'b_partial.json',
            ),
          ]),
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('throws a single load error as is next to a valid bundle', () async {
      final tempDir = Directory.systemTemp.createTempSync('share_loc_r5_');
      try {
        final settingsFile = File('${tempDir.path}/settings.json')
          ..writeAsStringSync(File('example/settings.json').readAsStringSync());
        final brokenBundle = File('${tempDir.path}/a_broken.json')
          ..writeAsStringSync('{ not json');
        final validBundle = File('${tempDir.path}/b_valid.json')
          ..writeAsStringSync(
            jsonEncode({
              'languages': ['en', 'ua'],
              'keys': {},
            }),
          );
        when(() {
          return fileService.getFilesInDirectory(
            path: any(named: 'path'),
            extension: any(named: 'extension'),
          );
        }).thenAnswer((_) async => [brokenBundle, validBundle]);

        final result = await generationUseCase(settingsFile.path);

        expect(result.failed, isTrue);
        expect(result.exception, isA<InvalidJsonException>());
        expect(virtualFiles, isEmpty);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('cross-bundle duplicate blocks only the Android builder', () async {
      final tempDir = Directory.systemTemp.createTempSync('share_loc_n13a_');
      try {
        // Prefixes off, so the key "title" gives "title" in both bundles.
        final json =
            jsonDecode(File('example/settings.json').readAsStringSync())
                  as Map<String, dynamic>
              ..['android'] = {
                'destination_folder': '../example/results/android/values',
                'use_camel_case': false,
                'use_file_prefix_for_keys': false,
              };
        final settingsFile = File('${tempDir.path}/settings.json')
          ..writeAsStringSync(jsonEncode(json));
        final featureBundle = File('${tempDir.path}/feature_a.json')
          ..writeAsStringSync(_bundleJson('title'));
        final generalBundle = File('${tempDir.path}/general.json')
          ..writeAsStringSync(_bundleJson('title'));
        when(() {
          return fileService.getFilesInDirectory(
            path: any(named: 'path'),
            extension: any(named: 'extension'),
          );
        }).thenAnswer((_) async => [featureBundle, generalBundle]);

        final result = await generationUseCase(settingsFile.path);

        expect(result.succeeded, isTrue);
        expect(result.data.hasErrors, isTrue);
        expect(result.data.errors, hasLength(1));
        expect(
          result.data.errors.single,
          isA<DuplicateResourceNameException>()
              .having((e) => e.platform, 'platform', ResourcePlatform.android)
              .having((e) => e.otherBundleName, 'otherBundleName', isNotNull),
        );
        final paths = virtualFiles.map((f) => f.path).toList();
        expect(paths.where((p) => p.contains('/android/')), isEmpty);
        expect(paths.where((p) => p.contains('/flutter/')), hasLength(6));
        expect(paths.where((p) => p.contains('/ios/')), hasLength(4));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('skipped Android builder still reports per-bundle errors', () async {
      final tempDir = Directory.systemTemp.createTempSync('share_loc_n17_');
      try {
        final json =
            jsonDecode(File('example/settings.json').readAsStringSync())
                  as Map<String, dynamic>
              ..['android'] = {
                'destination_folder': '../example/results/android/values',
                'use_camel_case': false,
                'use_file_prefix_for_keys': false,
              };
        final settingsFile = File('${tempDir.path}/settings.json')
          ..writeAsStringSync(jsonEncode(json));
        final featureBundle = File('${tempDir.path}/feature_a.json')
          ..writeAsStringSync(_bundleJson('title'));
        final generalBundle = File('${tempDir.path}/general.json')
          ..writeAsStringSync(_bundleJson('title'));
        // "1bad" is not a valid resource name on any platform.
        final badBundle = File('${tempDir.path}/zeta.json')
          ..writeAsStringSync(_bundleJson('1bad'));
        when(() {
          return fileService.getFilesInDirectory(
            path: any(named: 'path'),
            extension: any(named: 'extension'),
          );
        }).thenAnswer((_) async => [featureBundle, generalBundle, badBundle]);

        final result = await generationUseCase(settingsFile.path);

        expect(result.succeeded, isTrue);
        final android = result.data.errors.where((e) {
          return (e is DuplicateResourceNameException &&
                  e.platform == ResourcePlatform.android) ||
              (e is InvalidResourceNameException &&
                  e.platform == ResourcePlatform.android);
        });
        expect(android.map((e) => e.runtimeType).toSet(), {
          DuplicateResourceNameException,
          InvalidResourceNameException,
        });
        expect(
          virtualFiles.where((f) => f.path.contains('/android/')),
          isEmpty,
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}

/// A bundle with one key "key" and the English and Ukrainian messages.
String _bundleJson(String key) {
  return jsonEncode({
    'languages': ['en', 'ua'],
    'keys': {
      key: {
        'comment': 'A title.',
        'arguments': [],
        'localizations': {'en': 'Title', 'ua': 'Заголовок'},
      },
    },
  });
}

class _FailingCodeGenerationUseCase extends CodeGenerationUseCase {
  const _FailingCodeGenerationUseCase(super.fileService);

  @override
  Task<void> call(SettingsDto settings, LocalizationDto localization) async {
    return TaskFailed<void>(UnexpectedException('builder failed'));
  }
}
