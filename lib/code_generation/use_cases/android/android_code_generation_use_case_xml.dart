part of 'android_code_generation_use_case.dart';

extension BuildAndroidLocalizationUseCaseXml on AndroidCodeGenerationUseCase {
  String generateXml(
    AndroidSettingsDto settings,
    SettingsLanguageDto language,
    LocalizationDto localization,
  ) {
    return '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
${generateStrings(settings, localization.keys, language.key)}
</resources>
''';
  }

  @visibleForTesting
  String generateStrings(
    AndroidSettingsDto settings,
    List<LocalizationKeyDto> keys,
    String languageKey,
  ) {
    //   <string name="loginEmail">Email</string>
    //   <string name="welcomeMessages">Hello, %1$s! You have %2$d new messages.</string>

    return keys
        .map((key) {
          final getter = buildLocaleItemGetter(settings, key, languageKey);
          return getter;
        })
        .join('\n\n');
  }

  @visibleForTesting
  String buildLocaleItemGetter(
    AndroidSettingsDto settings,
    LocalizationKeyDto key,
    String languageKey,
  ) {
    //   <string name="loginEmail">Email</string>
    //   <string name="welcomeMessages">Hello, %1$s! You have %2$d new messages.</string>
    final useCamelCase = settings.options.useCamelCase;
    final itemName = key.key.nullSafe((key) {
      return useCamelCase ? key.camelCase() : key.snakeCase();
    });

    final translation = key.translation
        .firstWhere((translation) {
          return translation.languageKey == languageKey;
        })
        .message
        .androidTranslationEscape()
        .androidArgumentsEscape(key.arguments);
    final description = key.translation
        .firstWhere((translation) {
          return translation.languageKey == settings.languages.first.key;
        })
        .message
        .androidDescriptionEscape();

    return '''
<!-- $description -->
<string name="$itemName">$translation</string>'''
        .pad(2);
  }
}
