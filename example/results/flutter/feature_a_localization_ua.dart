import 'feature_a_localization.dart';

// ignore_for_file: type=lint

/// The translations for Ua.
class FeatureALocalizationUa extends FeatureALocalization {
  FeatureALocalizationUa([String locale = 'ua']) : super(locale);

  @override
  String loginMessage(String username, String password) => 'Привіт $username, ваш пароль є $password';
      
  @override
  String get loginTitle => 'Сторінка Логіну';
      
  @override
  String get loginButton => 'Логін';
      
}
