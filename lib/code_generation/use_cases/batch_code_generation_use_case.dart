import 'package:meta/meta.dart';
import 'package:share_localization/code_generation/build_report.dart';
import 'package:share_localization/code_generation/use_cases/android/android_code_generation_use_case.dart';
import 'package:share_localization/code_generation/use_cases/code_generation_use_case.dart';
import 'package:share_localization/code_generation/use_cases/flutter/flutter_code_generation_use_case.dart';
import 'package:share_localization/code_generation/use_cases/ios/ios_code_generation_use_case.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';
import 'package:share_localization/settings/settings.dart';

/// Settings, loaded localizations and the skipped verification exceptions.
typedef LoadResult = (
  SettingsDto,
  List<LocalizationDto>,
  List<VerificationLocalizationException>,
);

class BatchCodeGenerationUseCase {
  final SettingsLoaderUseCase settingsLoader;
  final LocalizationLoaderUseCase localizationLoader;
  final VerificationLocalizationUseCase verificationLocalization;
  final List<CodeGenerationUseCase> builders;
  final FileService fileService;

  const BatchCodeGenerationUseCase(
    this.settingsLoader,
    this.localizationLoader,
    this.verificationLocalization,
    this.builders,
    this.fileService,
  );

  factory BatchCodeGenerationUseCase.all({
    FileService fileService = const FileService(),
  }) {
    return BatchCodeGenerationUseCase(
      const SettingsLoaderUseCase(),
      const LocalizationLoaderUseCase(),
      const VerificationLocalizationUseCase(
        skipErrorTypes: [VerificationLocalizationExtraArgumentException],
      ),
      [
        FlutterCodeGenerationUseCase(fileService),
        IosCodeGenerationUseCase(fileService),
        AndroidCodeGenerationUseCase(fileService),
      ],
      fileService,
    );
  }

  Task<BuildReport> call(String settingsFilepath) {
    return runAppTaskSafely(() async {
      final (settings, localizations, skipped) = await load(settingsFilepath);
      final all = <AppException>[...skipped];
      // A builder with a cross-bundle clash is skipped for every bundle.
      final clashes = _crossBundleErrors(settings, localizations);
      for (final errors in clashes.values) {
        all.addAll(errors);
      }
      final skippedBuilders = clashes.keys.toSet();
      for (final localization in localizations) {
        all.addAll(await build(settings, localization, skip: skippedBuilders));
      }
      return BuildReport(all);
    });
  }

  @visibleForTesting
  Future<LoadResult> load(String settingsFilepath) async {
    final settingsTask = await settingsLoader(settingsFilepath);
    if (settingsTask.failed) {
      throw settingsTask.exception;
    }
    final settings = settingsTask.data;

    final sourceFiles = await fileService.getFilesInDirectory(
      path: settings.sourcesFolder,
      extension: '.json',
    );

    final localizationsTasks = await Future.wait(
      sourceFiles.map((file) => localizationLoader(file.path)),
    );
    final (localizations, loadErrors) = _splitTasks(localizationsTasks);
    _throwErrors(loadErrors);

    final verificationTasks = await Future.wait(
      localizations.map((localization) {
        return verificationLocalization(settings, localization);
      }),
    );
    final (skippedLists, verificationErrors) = _splitTasks(verificationTasks);
    _throwErrors(verificationErrors);

    return (settings, localizations, skippedLists.expand((e) => e).toList());
  }

  /// Splits [results] into the data of the succeeded tasks and the exceptions
  /// of the failed ones, both in input order.
  (List<T>, List<AppException>) _splitTasks<T>(List<TaskResult<T>> results) {
    final data = <T>[];
    final errors = <AppException>[];
    for (final result in results) {
      if (result.failed) {
        errors.add(result.exception);
      } else {
        data.add(result.data);
      }
    }
    return (data, errors);
  }

  /// Throws the only error as is, or all of them as one [CompositeException]
  /// with nested composites flattened, so every error is reported.
  void _throwErrors(List<AppException> errors) {
    if (errors.isEmpty) {
      return;
    }
    if (errors.length == 1) {
      throw errors.single;
    }
    throw CompositeException([
      for (final error in errors)
        if (error is CompositeException) ...error.exceptions else error,
    ]);
  }

  /// The cross-bundle errors of each builder that has any.
  Map<CodeGenerationUseCase, List<AppException>> _crossBundleErrors(
    SettingsDto settings,
    List<LocalizationDto> localizations,
  ) {
    final result = <CodeGenerationUseCase, List<AppException>>{};
    for (final builder in builders) {
      final errors = builder.validateBundles(settings, localizations);
      if (errors.isNotEmpty) {
        result[builder] = errors;
      }
    }
    return result;
  }

  @visibleForTesting
  Future<List<AppException>> build(
    SettingsDto settings,
    LocalizationDto localization, {
    Set<CodeGenerationUseCase> skip = const {},
  }) async {
    final exceptions = <AppException>[];
    for (final builder in builders) {
      if (skip.contains(builder)) {
        // Nothing is written, but the bundle's own errors are still reported.
        final error = builder.validateBundle(settings, localization);
        if (error != null) {
          exceptions.add(error);
        }
        continue;
      }
      final buildTask = await builder(settings, localization);
      if (buildTask.failed) {
        exceptions.add(buildTask.exception);
      }
    }
    return exceptions;
  }
}
