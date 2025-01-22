import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'general_en.dart';
import 'general_ua.dart';

// ignore_for_file: type=lint

abstract class General {
  General(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static General of(BuildContext context) {
    return Localizations.of<General>(context, General)!;
  }

  static const LocalizationsDelegate<General> delegate = _GeneralDelegate();

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
      
}

class _GeneralDelegate
    extends LocalizationsDelegate<General> {
  const _GeneralDelegate();

  @override
  Future<General> load(Locale locale) {
    return SynchronousFuture<General>(
        lookupGeneral(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ua'].contains(locale.languageCode);

  @override
  bool shouldReload(_GeneralDelegate old) => false;
}

General lookupGeneral(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return GeneralEn();
    case 'ua': return GeneralUa();
  }

  throw FlutterError(
      'General.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
