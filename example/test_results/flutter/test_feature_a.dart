import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'test_feature_a_en.dart';
import 'test_feature_a_de.dart';

// ignore_for_file: type=lint

abstract class TestFeatureA {
  TestFeatureA(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static TestFeatureA of(BuildContext context) {
    return Localizations.of<TestFeatureA>(context, TestFeatureA)!;
  }

  static const LocalizationsDelegate<TestFeatureA> delegate = _TestFeatureADelegate();

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

class _TestFeatureADelegate
    extends LocalizationsDelegate<TestFeatureA> {
  const _TestFeatureADelegate();

  @override
  Future<TestFeatureA> load(Locale locale) {
    return SynchronousFuture<TestFeatureA>(
        lookupTestFeatureA(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'de'].contains(locale.languageCode);

  @override
  bool shouldReload(_TestFeatureADelegate old) => false;
}

TestFeatureA lookupTestFeatureA(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return TestFeatureAEn();
    case 'de': return TestFeatureADe();
  }

  throw FlutterError(
      'TestFeatureA.delegate failed to load unsupported locale "$locale". This is likely '
          'an issue with the localizations generation tool. Please file an issue '
          'on GitHub with a reproducible sample app and the gen-l10n configuration '
          'that was used.');
}