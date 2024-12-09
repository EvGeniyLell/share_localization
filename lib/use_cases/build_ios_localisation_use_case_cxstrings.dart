part of 'build_ios_localisation_use_case.dart';

@visibleForTesting
extension BuildIosLocalisationUseCaseCxstrings on BuildIosLocalisationUseCase {
  String buildCXStrings(
    SettingsDto settings,
    LocalisationDto localisation,
  ) {
    final defaultLanguage = settings.languages.first.key;
    final stringsItems = localisation.keys.map(buildCXStringsItem).join(',\n');
    return '''
{
  "sourceLanguage" : "$defaultLanguage",
  "strings" : {
$stringsItems
  },
  "version" : "1.0"
}''';
  }

  String buildCXStringsItem(LocalisationKeyDto key) {
    final translations = key.translation.map((translation) {
      return buildCXStringsItemTranslation(key, translation);
    }).join(',\n');
    return '''
    "${key.iosCXStringKey()}" : {
      "extractionState" : "manual",
      "localizations" : {
$translations
      }
    }''';
  }

  String buildCXStringsItemTranslation(
    LocalisationKeyDto key,
    LocalisationKeyTranslationDto translation,
  ) {
    return '''
        "${translation.languageKey}" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "${translation.iosMessage(key.arguments)}"
          }
        }''';
  }
}
