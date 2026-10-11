import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'test_numbers_localization_en.dart';
import 'test_numbers_localization_de.dart';

// ignore_for_file: type=lint

abstract class TestNumbersLocalization {
  TestNumbersLocalization(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static TestNumbersLocalization of(BuildContext context) {
    return Localizations.of<TestNumbersLocalization>(context, TestNumbersLocalization)!;
  }

  static const LocalizationsDelegate<TestNumbersLocalization> delegate = _TestNumbersLocalizationDelegate();

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
    Locale('de'),
  ];

  /// This is a report about a file.
  ///
  /// In en, this message translates to:
  /// **'File {title} has {pages} pages and weighs {size} MB'**
  String fileReport(String title, double size, int pages);

}

class _TestNumbersLocalizationDelegate
    extends LocalizationsDelegate<TestNumbersLocalization> {
  const _TestNumbersLocalizationDelegate();

  @override
  Future<TestNumbersLocalization> load(Locale locale) {
    return SynchronousFuture<TestNumbersLocalization>(
        lookupTestNumbersLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'de'].contains(locale.languageCode);

  @override
  bool shouldReload(_TestNumbersLocalizationDelegate old) => false;
}

TestNumbersLocalization lookupTestNumbersLocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return TestNumbersLocalizationEn();
    case 'de': return TestNumbersLocalizationDe();
  }

  throw FlutterError(
      'TestNumbersLocalization.delegate failed to load unsupported locale "$locale". This is likely '
          'an issue with the localizations generation tool. Please file an issue '
          'on GitHub with a reproducible sample app and the gen-l10n configuration '
          'that was used.');
}