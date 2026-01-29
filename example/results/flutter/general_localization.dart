import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'general_localization_en.dart';
import 'general_localization_ua.dart';

// ignore_for_file: type=lint

abstract class GeneralLocalization {
  GeneralLocalization(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static GeneralLocalization of(BuildContext context) {
    return Localizations.of<GeneralLocalization>(context, GeneralLocalization)!;
  }

  static const LocalizationsDelegate<GeneralLocalization> delegate = _GeneralLocalizationDelegate();

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
    Locale('en'),
    Locale('ua'),
  ];
  
  /// This a body of error notification message.
  ///
  /// In en, this message translates to:
  /// **'The {file_name} has size {current_size}, it is biggest then maximum {maximum_size}.'**
  String fileSizeErrorBody(String fileName, double currentSize, double maximumSize);
      
  /// This is a attention message for file size.
  ///
  /// In en, this message translates to:
  /// **'File should be less or equal to {maximum_size} MB.'**
  String fileSizeAttention(int maximumSize);
      
  /// This is a title for file size error screen
  ///
  /// In en, this message translates to:
  /// **'Attention! The file size is too big.'**
  String get fileSizeTitle;

  /// This is a escape test message
  ///
  /// In en, this message translates to:
  /// **'Couldn't!\n Test.'**
  String get escapeTest;

}

class _GeneralLocalizationDelegate
    extends LocalizationsDelegate<GeneralLocalization> {
  const _GeneralLocalizationDelegate();

  @override
  Future<GeneralLocalization> load(Locale locale) {
    return SynchronousFuture<GeneralLocalization>(
        lookupGeneralLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ua'].contains(locale.languageCode);

  @override
  bool shouldReload(_GeneralLocalizationDelegate old) => false;
}

GeneralLocalization lookupGeneralLocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return GeneralLocalizationEn();
    case 'ua': return GeneralLocalizationUa();
  }

  throw FlutterError(
      'GeneralLocalization.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
