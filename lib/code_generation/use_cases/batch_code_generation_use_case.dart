import 'package:meta/meta.dart';
import 'package:share_localization/code_generation/use_cases/code_generation_use_case.dart';
import 'package:share_localization/code_generation/use_cases/flutter/flutter_code_generation_use_case.dart';
import 'package:share_localization/code_generation/use_cases/ios/ios_code_generation_use_case.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';
import 'package:share_localization/settings/settings.dart';

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
        skipErrorTypes: [
          VerificationLocalizationExtraArgumentException,
        ],
      ),
      [
        FlutterCodeGenerationUseCase(fileService),
        IosCodeGenerationUseCase(fileService),
      ],
      fileService,
    );
  }

  Task<void> call(String settingsFilepath) {
    return runAppTaskSafely(() async {
      final (settings, localizations) = await load(settingsFilepath);
      final exceptions = <AppException>{};
      for (final localization in localizations) {
        final subExceptions = await build(settings, localization);
        exceptions.addAll(subExceptions);
      }
      if (exceptions.isNotEmpty) {
        throw CompositeException(exceptions.toList());
      }
    });
  }

  @visibleForTesting
  Future<(SettingsDto, List<LocalizationDto>)> load(
    String settingsFilepath,
  ) async {
    final settingsTask = await settingsLoader(settingsFilepath);
    if (settingsTask.failed) {
      throw settingsTask.exception;
    }
    final settings = settingsTask.data;

    final sourceFiles = await fileService.getFilesInDirectory(
      path: settings.sourcesFolder,
      extension: '.json',
    );

    final localizationsTasks = sourceFiles.map((file) async {
      final localizationTask = await localizationLoader(file.path);
      if (localizationTask.failed) {
        throw localizationTask.exception;
      }
      return localizationTask.data;
    });

    final localizations = await Future.wait(localizationsTasks);

    localizations.forEach((localization) async {
      final verificationTask =
          await verificationLocalization(settings, localization);
      if (verificationTask.failed) {
        throw verificationTask.exception;
      }
      return verificationTask.data;
    });

    return (settings, localizations);
  }

  @visibleForTesting
  Future<List<AppException>> build(
    SettingsDto settings,
    LocalizationDto localization,
  ) async {
    final exceptions = <AppException>[];
    for (final builder in builders) {
      final buildTask = await builder(settings, localization);
      if (buildTask.failed) {
        exceptions.add(buildTask.exception);
      }
    }
    return exceptions;
  }
}
