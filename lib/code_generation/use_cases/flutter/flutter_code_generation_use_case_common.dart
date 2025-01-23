part of 'flutter_code_generation_use_case.dart';

extension BuildFlutterLocalizationUseCaseCommon
    on FlutterCodeGenerationUseCase {
  @visibleForTesting
  String generateCommon(
    settings.SettingsDto settings,
    LocalizationDto localization,
  ) {
    final baseFilename = localization.name.baseFilename();
    final defaultLanguage = settings.languages.first.key;

    // import 'example_localization_en.dart';
    final importLocalizations = localization.languages.map((language) {
      return "import '${baseFilename}_${language.key}.dart';";
    }).join('\n');

    // ExampleLocalization
    final className = baseFilename.camelCase().capitalize();

    // Locale('en'),
    final supportedLocales = localization.languages.map((language) {
      return "Locale('${language.key}'),";
    }).join('\n    ');

    // 'en', 'de'
    final languageCodes = localization.languages.map((language) {
      return "'${language.key}'";
    }).join(', ');

    // case 'en': return ${className}En();
    final languageCodesCases = localization.languages.map((language) {
      return "case '${language.key}':"
          ' return $className${language.key.capitalize()}();';
    }).join('\n    ');

    // /// Dialog message shown when a document is being created
    // ///
    // /// In en, this message translates to:
    // /// **'Please wait whilst the document is created'**
    // String get creatingDocumentBody;
    //
    // /// Error message shown when max file size is reached
    // ///
    // /// In en, this message translates to:
    // /// **'Total file size must be less than {fileSize}'**
    // String maxFileSizeError(String fileSize);
    final items = localization.keys.map((key) {
      final comment = key.comment;
      final translation = key.translation.firstWhere((translation) {
        return translation.languageKey == defaultLanguage;
      }).message;
      final getter = buildCommonItemGetter(key);
      return '''
  /// $comment
  ///
  /// In $defaultLanguage, this message translates to:
  /// **'$translation'**
  $getter
      ''';
    }).join('\n');

    return '''
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

$importLocalizations

// ignore_for_file: type=lint

abstract class $className {
  $className(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static $className of(BuildContext context) {
    return Localizations.of<$className>(context, $className)!;
  }

  static const LocalizationsDelegate<$className> delegate = _${className}Delegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.  
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    $supportedLocales
  ];
  \n$items
}

class _${className}Delegate
    extends LocalizationsDelegate<$className> {
  const _${className}Delegate();

  @override
  Future<$className> load(Locale locale) {
    return SynchronousFuture<$className>(
        lookup$className(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>[$languageCodes].contains(locale.languageCode);

  @override
  bool shouldReload(_${className}Delegate old) => false;
}

$className lookup$className(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    $languageCodesCases
  }

  throw FlutterError(
      '$className.delegate failed to load unsupported locale "\$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
''';
  }

  @visibleForTesting
  String buildCommonItemGetter(LocalizationKeyDto key) {
    // Example:
    // String get creatingDocumentBody;
    // or
    // String maxFileSizeError(String fileSize);
    final itemName = key.key.camelCase();
    if (key.arguments.isEmpty) {
      return 'String get $itemName;';
    }
    final arguments = key.arguments.map((argument) {
      final typeName = argument.type.dartType;
      final argumentName = argument.name.camelCase();
      return '$typeName $argumentName';
    }).join(', ');

    return 'String $itemName($arguments);';
  }
}
