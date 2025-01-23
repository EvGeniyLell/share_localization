import 'feature_a.dart';

// ignore_for_file: type=lint

/// The translations for En.
class FeatureAEn extends FeatureA {
  FeatureAEn([String locale = 'en']) : super(locale);

  @override
  String loginMessage(String username, String password) => 'Hi $username, your password is $password';

  @override
  String get loginTitle => 'Login Page';

  @override
  String get loginButton => 'Login';

}
