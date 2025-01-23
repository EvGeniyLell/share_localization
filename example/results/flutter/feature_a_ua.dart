import 'feature_a.dart';

// ignore_for_file: type=lint

/// The translations for Ua.
class FeatureAUa extends FeatureA {
  FeatureAUa([String locale = 'ua']) : super(locale);

  @override
  String loginMessage(String username, String password) => 'Привіт $username, ваш пароль є $password';

  @override
  String get loginTitle => 'Сторінка Логіну';

  @override
  String get loginButton => 'Логін';

}
