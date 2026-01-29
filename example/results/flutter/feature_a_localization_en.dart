import 'feature_a_localization.dart';

// ignore_for_file: type=lint

/// The translations for En.
class FeatureALocalizationEn extends FeatureALocalization {
  FeatureALocalizationEn([String locale = 'en']) : super(locale);

  @override
  String loginMessage(String username, String password) => 'Hi $username, your password is $password';
      
  @override
  String get loginTitle => 'Login Page';
      
  @override
  String get loginButton => 'Login';
      
}
