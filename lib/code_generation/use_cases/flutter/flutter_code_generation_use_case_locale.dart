part of 'flutter_code_generation_use_case.dart';

extension BuildFlutterLocalizationUseCaseLocale
    on FlutterCodeGenerationUseCase {
  String generateLocale(
    FlutterSettingsDto settings,
    SettingsLanguageDto language,
    LocalizationDto localization,
  ) {
    final baseFilename = localization.name.baseFilename();

    // import 'example_localization.dart';
    final importLocalization = "import '$baseFilename.dart';";

    // ExampleLocalization
    final baseClassName = baseFilename.camelCase().capitalize();

    // ExampleLocalizationEn
    final className = '$baseClassName${language.key.capitalize()}';

    //   @override
    //   String get creatingDocumentBody =>
    //       'Please wait whilst the document is created';
    //
    //   @override
    //   String maxFileSizeError(String fileSize) {
    //     return 'Total file size must be less than $fileSize';
    //   }
    final items = localization.keys
        .map((key) {
          final getter = buildLocaleItemGetter(key, language.key);
          return '''
  @override
  $getter
      ''';
        })
        .join('\n');

    return '''
$importLocalization

// ignore_for_file: type=lint

/// The translations for ${language.key.capitalize()}.
class $className extends $baseClassName {
  $className([String locale = '${language.key}']) : super(locale);

$items
}
''';
  }

  @visibleForTesting
  String buildLocaleItemGetter(LocalizationKeyDto key, String languageKey) {
    //   @override
    //   String get creatingDocumentBody =>
    //       'Please wait whilst the document is created';
    //
    //   @override
    //   String maxFileSizeError(String fileSize) {
    //     return 'Total file size must be less than $fileSize';
    //   }
    final itemName = key.key.camelCase();
    final translation = key.translation
        .firstWhere((translation) {
          return translation.languageKey == languageKey;
        })
        .message
        .flutterEscape();

    if (key.arguments.isEmpty) {
      return 'String get $itemName => '
          "'$translation';";
    }
    final arguments = key.arguments
        .map((argument) {
          final typeName = argument.type.dartType;
          final argumentName = argument.name.camelCase();
          return '$typeName $argumentName';
        })
        .join(', ');

    return 'String $itemName($arguments) => '
        "'$translation';";
  }
}
