part of 'ios_code_generation_use_case.dart';

@visibleForTesting
extension BuildIosLocalizationUseCaseSwift on IosCodeGenerationUseCase {
  String generateSwift(
    IosSettingsDto settings,
    LocalizationDto localization,
  ) {
    final defaultLanguage = settings.languages.first;
    final baseFilename = localization.name.baseFilename();
    final localizationName = baseFilename.camelCase().capitalize();
    final localizationBundle = settings.options.bundleName.nullSafe((name) {
      if (name == null) {
        return '';
      }
      return ', bundle: .$name';
    });
    final getters = localization.keys.map((key) {
      final translation = key.translation.firstWhere((translation) {
        return translation.languageKey == defaultLanguage.key;
      });
      return buildXCStringsItemTranslation(defaultLanguage, key, translation);
    }).join('\n\n');
    return '''
class ${localizationName}Localization {
  private static func l(_ key: String.LocalizationValue) -> String {
    return String(localized: key, table: "$localizationName"$localizationBundle)
  }
  
$getters  
}
''';
  }

  String buildXCStringsItemTranslation(
    SettingsLanguageDto language,
    LocalizationKeyDto key,
    LocalizationKeyTranslationDto translation,
  ) {
    final comment = key.comment;
    final defaultLanguage = language.key;
    final translation = key.translation.firstWhere((translation) {
      return translation.languageKey == defaultLanguage;
    }).message;
    final getter = buildSwiftItemGetter(key);

    return '''
  /// $comment
  ///
  /// In $defaultLanguage, this message translates to:
  /// **'$translation'**
$getter''';
  }

  String buildSwiftItemGetter(LocalizationKeyDto key) {
    // Example:
    // static func loginMessage(_ name: String, _ pass: String) -> String {
    // or
    // static var testA: String {
    final itemName = key.key.camelCase();
    if (key.arguments.isEmpty) {
      return '''
  static var $itemName : String {
    l("${key.iosXCStringKey()}")
  }''';
    }
    final arguments = key.arguments.map((argument) {
      final typeName = argument.type.iosType;
      final argumentName = argument.name.camelCase();
      return '_ $argumentName: $typeName';
    }).join(', ');

    return '''
  static func $itemName($arguments) -> String {
    l("${key.iosSwiftKey()}")
  }''';
  }
}
