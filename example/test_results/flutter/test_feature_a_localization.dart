import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'test_feature_a_localization_en.dart';
import 'test_feature_a_localization_de.dart';

// ignore_for_file: type=lint

abstract class TestFeatureALocalization {
  TestFeatureALocalization(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static TestFeatureALocalization of(BuildContext context) {
    return Localizations.of<TestFeatureALocalization>(context, TestFeatureALocalization)!;
  }

  static const LocalizationsDelegate<TestFeatureALocalization> delegate = _TestFeatureALocalizationDelegate();

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

  /// This a body of login message.
  ///
  /// In en, this message translates to:
  /// **'Hi {username}, your password is {password}'**
  String loginMessage(String username, String password);

  /// This is a title for login screen.
  ///
  /// In en, this message translates to:
  /// **'Login Page'**
  String get loginTitle;

}

class _TestFeatureALocalizationDelegate
    extends LocalizationsDelegate<TestFeatureALocalization> {
  const _TestFeatureALocalizationDelegate();

  @override
  Future<TestFeatureALocalization> load(Locale locale) {
    return SynchronousFuture<TestFeatureALocalization>(
        lookupTestFeatureALocalization(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'de'].contains(locale.languageCode);

  @override
  bool shouldReload(_TestFeatureALocalizationDelegate old) => false;
}

TestFeatureALocalization lookupTestFeatureALocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return TestFeatureALocalizationEn();
    case 'de': return TestFeatureALocalizationDe();
  }

  throw FlutterError(
      'TestFeatureALocalization.delegate failed to load unsupported locale "$locale". This is likely '
          'an issue with the localizations generation tool. Please file an issue '
          'on GitHub with a reproducible sample app and the gen-l10n configuration '
          'that was used.');
}