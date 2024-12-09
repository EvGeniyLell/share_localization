part of 'build_ios_localisation_use_case.dart';

@visibleForTesting
extension BuildIosLocalisationUseCaseSwift on BuildIosLocalisationUseCase {
  String buildSwift(
    SettingsDto settings,
    LocalisationDto localisation,
  ) {
    final defaultLanguage = settings.languages.first;
    final baseFilename = localisation.name.baseFilename();
    final localisationName = baseFilename.camelCase().capitalize();
    print('localisationName: ${localisation.name}');
    final getters = localisation.keys.map((key) {
      final translation = key.translation.firstWhere((translation) {
        return translation.languageKey == defaultLanguage.key;
      });
      return buildCXStringsItemTranslation(defaultLanguage, key, translation);
    }).join('\n\n');
    return '''
class $localisationName {
  private static let table: String = "$localisationName"
  
$getters  
}
''';
  }

  String buildCXStringsItemTranslation(
    LanguageDto language,
    LocalisationKeyDto key,
    LocalisationKeyTranslationDto translation,
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

  String buildSwiftItemGetter(LocalisationKeyDto key) {
    // Example:
    // static func loginMessage(_ name: String, _ pass: String) -> String {
    // or
    // static var testA: String {
    final itemName = key.key.camelCase();
    if (key.arguments.isEmpty) {
      return '''
  static var $itemName : String {
    String(localized:"${key.iosCXStringKey()}", table: table)
  }''';
    }
    final arguments = key.arguments.map((argument) {
      final typeName = argument.type.iosType;
      final argumentName = argument.name.camelCase();
      return '_ $argumentName: $typeName';
    }).join(', ');

    return '''
  static func $itemName($arguments) -> String {
    String(localized:"${key.iosSwiftKey()}", table: table)
  }''';
  }
}
