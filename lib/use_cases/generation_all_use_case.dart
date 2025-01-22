import 'dart:io' as io;

import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/exceptions/exceptions.dart';
import 'package:share_localisation/use_cases/build_flutter_localisation_use_case.dart';
import 'package:share_localisation/use_cases/build_ios_localisation_use_case.dart';
import 'package:share_localisation/use_cases/build_localisation_use_case.dart';
import 'package:share_localisation/use_cases/localisation_loader_use_case.dart';
import 'package:share_localisation/use_cases/settings_loader_use_case.dart';
import 'package:share_localisation/use_cases/verification_localisation_use_case.dart';
import 'package:share_localisation/utils/common.dart';

class GenerationUseCase {
  final SettingsLoaderUseCase settingsLoader;
  final LocalisationLoaderUseCase localisationLoader;
  final VerificationLocalisationUseCase verificationLocalisation;
  final List<BuildLocalisationUseCase> builders;

  const GenerationUseCase(
    this.settingsLoader,
    this.localisationLoader,
    this.verificationLocalisation,
    this.builders,
  );

  factory GenerationUseCase.all() {
    return const GenerationUseCase(
      SettingsLoaderUseCase(),
      LocalisationLoaderUseCase(),
      VerificationLocalisationUseCase(
        skipErrorTypes: [
          VerificationLocalisationExtraArgumentException,
        ],
      ),
      [
        BuildFlutterLocalisationUseCase(),
        BuildIosLocalisationUseCase(),
      ],
    );
  }

  AppTask<void> call(String settingsFilepath) {
    return runAppTaskSafely(() async {
      final (settings, localisations) = await load(settingsFilepath);
      final exceptions = <AppException>{};
      for (final localisation in localisations) {
        final subExceptions = await build(settings, localisation);
        exceptions.addAll(subExceptions);
      }
      if (exceptions.isNotEmpty) {
        throw CompositeException(exceptions.toList());
      }
    });
  }

  Future<(SettingsDto, List<LocalisationDto>)> load(
    String settingsFilepath,
  ) async {
    final settingsTask = await settingsLoader(settingsFilepath);
    if (settingsTask.failed) {
      throw settingsTask.exception;
    }
    final settings = settingsTask.data;

    final localisationsTasks = io.Directory(settings.sourcesFolder)
        .listSync()
        .whereType<io.File>()
        .where((file) => file.path.endsWith('.json'))
        .map((file) async {
      final localisationTask = await localisationLoader(file.path);
      if (localisationTask.failed) {
        throw localisationTask.exception;
      }
      return localisationTask.data;
    });

    final localisations = await Future.wait(localisationsTasks);

    localisations.forEach((localisation) async {
      final verificationTask =
          await verificationLocalisation(settings, localisation);
      if (verificationTask.failed) {
        throw verificationTask.exception;
      }
      return verificationTask.data;
    });

    return (settings, localisations);
  }

  Future<List<AppException>> build(
    SettingsDto settings,
    LocalisationDto localisation,
  ) async {
    final exceptions = <AppException>[];
    for (final builder in builders) {
      final buildTask = await builder(settings, localisation);
      if (buildTask.failed) {
        exceptions.add(buildTask.exception);
      }
    }
    return exceptions;
  }
}
