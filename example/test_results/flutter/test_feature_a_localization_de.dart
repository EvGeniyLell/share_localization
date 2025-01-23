import 'test_feature_a_localization.dart';

// ignore_for_file: type=lint

/// The translations for De.
class TestFeatureALocalizationDe extends TestFeatureALocalization {
  TestFeatureALocalizationDe([String locale = 'de']) : super(locale);

  @override
  String loginMessage(String username, String password) => 'Heilegh $username, dein passdahwordther ist $password';

  @override
  String get loginTitle => 'Ther Loghingher Paghedguahter';

}