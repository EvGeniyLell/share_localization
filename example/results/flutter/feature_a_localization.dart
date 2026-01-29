import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'feature_a_localization_en.dart';
import 'feature_a_localization_ua.dart';

// ignore_for_file: type=lint

abstract class FeatureALocalization {
  FeatureALocalization(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FeatureALocalization of(BuildContext context) {
    return Localizations.of<FeatureALocalization>(context, FeatureALocalization)!;
  }

  static const LocalizationsDelegate<FeatureALocalization> delegate = _FeatureALocalizationDelegate();

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

class _FeatureALocalizationDelegate
    extends LocalizationsDelegate<FeatureALocalization> {
  const _FeatureALocalizationDelegate();

  @override
  Future<FeatureALocalization> load(Locale locale) {
    return SynchronousFuture<FeatureALocalization>(
        lookupFeatureALocalization(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ua'].contains(locale.languageCode);

  @override
  bool shouldReload(_FeatureALocalizationDelegate old) => false;
}

FeatureALocalization lookupFeatureALocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return FeatureALocalizationEn();
    case 'ua': return FeatureALocalizationUa();
  }

  throw FlutterError(
      'FeatureALocalization.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
