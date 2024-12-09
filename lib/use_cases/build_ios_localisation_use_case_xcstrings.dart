part of 'build_ios_localisation_use_case.dart';

@visibleForTesting
extension BuildIosLocalisationUseCaseXCStrings on BuildIosLocalisationUseCase {
  String buildXCStrings(
    SettingsDto settings,
    LocalisationDto localisation,
  ) {
    final defaultLanguage = settings.languages.first.key;
    final stringsItems = localisation.keys.map(buildXCStringsItem).join(',\n');
    return '''
{
  "sourceLanguage" : "$defaultLanguage",
  "strings" : {
$stringsItems
  },
  "version" : "1.0"
}''';
  }

  String buildXCStringsItem(LocalisationKeyDto key) {
    final translations = key.translation.map((translation) {
      return buildXCStringsItemTranslation(key, translation);
    }).join(',\n');
    return '''
    "${key.iosXCStringKey()}" : {
      "comment" : "${key.comment}",
      "extractionState" : "manual",
      "localizations" : {
$translations
      }
    }''';
  }

  String buildXCStringsItemTranslation(
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
