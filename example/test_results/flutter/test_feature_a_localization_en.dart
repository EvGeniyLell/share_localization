import 'test_feature_a_localization.dart';

// ignore_for_file: type=lint

/// The translations for En.
class TestFeatureALocalizationEn extends TestFeatureALocalization {
  TestFeatureALocalizationEn([String locale = 'en']) : super(locale);

  @override
  String loginMessage(String username, String password) => 'Hi $username, your password is $password';

  @override
  String get loginTitle => 'Login Page';

}