import 'dart:io' as io;

import 'package:share_localization/dtos/dtos.dart';
import 'package:share_localization/exceptions/exceptions.dart';
import 'package:share_localization/use_cases/flutter/build_flutter_localization_use_case.dart';
import 'package:share_localization/use_cases/ios/build_ios_localization_use_case.dart';
import 'package:share_localization/use_cases/build_localization_use_case.dart';
import 'package:share_localization/use_cases/localization_loader_use_case.dart';
import 'package:share_localization/use_cases/settings_loader_use_case.dart';
import 'package:share_localization/use_cases/verification_localization_use_case.dart';
import 'package:share_localization/utils/common.dart';

class GenerationUseCase {
  final SettingsLoaderUseCase settingsLoader;
  final LocalizationLoaderUseCase localizationLoader;
  final VerificationLocalizationUseCase verificationLocalization;
  final List<BuildLocalizationUseCase> builders;

  const GenerationUseCase(
    this.settingsLoader,
    this.localizationLoader,
    this.verificationLocalization,
    this.builders,
  );

  factory GenerationUseCase.all() {
    return const GenerationUseCase(
      SettingsLoaderUseCase(),
      LocalizationLoaderUseCase(),
      VerificationLocalizationUseCase(
        skipErrorTypes: [
          VerificationLocalizationExtraArgumentException,
        ],
      ),
      [
        BuildFlutterLocalizationUseCase(),
        BuildIosLocalizationUseCase(),
      ],
    );
  }

  AppTask<void> call(String settingsFilepath) {
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

  Future<(SettingsDto, List<LocalizationDto>)> load(
    String settingsFilepath,
  ) async {
    final settingsTask = await settingsLoader(settingsFilepath);
    if (settingsTask.failed) {
      throw settingsTask.exception;
    }
    final settings = settingsTask.data;

    final localizationsTasks = io.Directory(settings.sourcesFolder)
        .listSync()
        .whereType<io.File>()
        .where((file) => file.path.endsWith('.json'))
        .map((file) async {
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
