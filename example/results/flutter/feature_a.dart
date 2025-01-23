import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'feature_a_en.dart';
import 'feature_a_ua.dart';

// ignore_for_file: type=lint

abstract class FeatureA {
  FeatureA(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FeatureA of(BuildContext context) {
    return Localizations.of<FeatureA>(context, FeatureA)!;
  }

  static const LocalizationsDelegate<FeatureA> delegate = _FeatureADelegate();

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

  /// This a body of login message.
  ///
  /// In en, this message translates to:
  /// **'Hi {username}, your password is {password}'**
  String loginMessage(String username, String password);

  /// This is a title for login screen
  ///
  /// In en, this message translates to:
  /// **'Login Page'**
  String get loginTitle;

  /// This is a login button on login screen
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

}

class _FeatureADelegate
    extends LocalizationsDelegate<FeatureA> {
  const _FeatureADelegate();

  @override
  Future<FeatureA> load(Locale locale) {
    return SynchronousFuture<FeatureA>(
        lookupFeatureA(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ua'].contains(locale.languageCode);

  @override
  bool shouldReload(_FeatureADelegate old) => false;
}

FeatureA lookupFeatureA(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return FeatureAEn();
    case 'ua': return FeatureAUa();
  }

  throw FlutterError(
      'FeatureA.delegate failed to load unsupported locale "$locale". This is likely '
          'an issue with the localizations generation tool. Please file an issue '
          'on GitHub with a reproducible sample app and the gen-l10n configuration '
          'that was used.');
}
