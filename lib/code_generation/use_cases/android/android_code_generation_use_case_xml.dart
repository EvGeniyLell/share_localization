part of 'android_code_generation_use_case.dart';

extension BuildAndroidLocalizationUseCaseXml on AndroidCodeGenerationUseCase {
  String generateXml(
    AndroidSettingsDto settings,
    SettingsLanguageDto language,
    LocalizationDto localization,
  ) {
    final localizationKeyPrefix =
        switch (settings.options.useFilePrefixForKeys) {
          true => localization.name.baseFilename(),
          false => '',
        };
    return '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
${generateStrings(settings, localizationKeyPrefix, localization.keys, language.key)}
</resources>
''';
  }

  @visibleForTesting
  String generateStrings(
    AndroidSettingsDto settings,
    String localizationKeyPrefix,
    List<LocalizationKeyDto> keys,
    String languageKey,
  ) {
    //   <string name="loginEmail">Email</string>
    //   <string name="welcomeMessages">Hello, %1$s! You have %2$d new messages.</string>

    return keys
        .map((key) {
          final getter = buildLocaleItemGetter(
            settings,
            localizationKeyPrefix,
            key,
            languageKey,
          );
          return getter;
        })
        .join('\n\n');
  }

  @visibleForTesting
  String buildLocaleItemGetter(
    AndroidSettingsDto settings,
    String localizationKeyPrefix,
    LocalizationKeyDto key,
    String languageKey,
  ) {
    //   <string name="loginEmail">Email</string>
    //   <string name="welcomeMessages">Hello, %1$s! You have %2$d new messages.</string>
    final useCamelCase = settings.options.useCamelCase;
    final itemName = key.key.nullSafe((key) {
      final fullKey = [localizationKeyPrefix, key]
          .where((s) => s.isNotEmpty)
          .join('_');
      return useCamelCase ? fullKey.camelCase() : fullKey.snakeCase();
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
