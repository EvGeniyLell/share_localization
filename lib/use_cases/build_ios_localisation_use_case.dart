import 'package:meta/meta.dart';
import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/exceptions/exceptions.dart';
import 'package:share_localisation/utils/common.dart';

class BuildIosLocalisationUseCase {
  const BuildIosLocalisationUseCase();

  AppTask<void> call(SettingsDto settings, LocalisationDto localisation) {
    return runAppTaskSafely(() async {
      // final localisationExceptions = checkLocalisation(settings, localisation);
      // if (localisationExceptions.isNotEmpty) {
      //   throw CompositeException(localisationExceptions);
      // }
      // final keyExceptions = checkKeys(settings, localisation);
      // if (keyExceptions.isNotEmpty) {
      //   throw CompositeException(keyExceptions);
      // }
    });
  }

  // @visibleForTesting
  // List<VerificationLocalisationException> checkLocalisation(
  //   SettingsDto settings,
  //   LocalisationDto localisation,
  // ) {
  //   return settings.languages.mapWhereEvery(
  //     localisation.languages,
  //     test: (settingsLanguage, localisationLanguage) {
  //       return settingsLanguage.key != localisationLanguage.key;
  //     },
  //     toElement: (settingsLanguage) {
  //       return VerificationLocalisationException.missingLanguage(
  //         language: settingsLanguage.key,
  //         sourceName: localisation.name,
  //       );
  //     },
  //   ).toList();
  // }
}
