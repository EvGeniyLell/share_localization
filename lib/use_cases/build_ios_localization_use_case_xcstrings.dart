part of 'build_ios_localization_use_case.dart';

@visibleForTesting
extension BuildIosLocalizationUseCaseXCStrings on BuildIosLocalizationUseCase {
  String buildXCStrings(
    SettingsDto settings,
    LocalizationDto localization,
  ) {
    final defaultLanguage = settings.languages.first.key;
    final stringsItems = localization.keys.map(buildXCStringsItem).join(',\n');
    return '''
{
  "sourceLanguage" : "$defaultLanguage",
  "strings" : {
$stringsItems
  },
  "version" : "1.0"
}''';
  }

  String buildXCStringsItem(LocalizationKeyDto key) {
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
    LocalizationKeyDto key,
    LocalizationKeyTranslationDto translation,
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
