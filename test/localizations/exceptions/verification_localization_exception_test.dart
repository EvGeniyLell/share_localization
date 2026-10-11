import 'package:share_localization/localizations/localizations.dart';
import 'package:test/test.dart';

void main() {
  group('VerificationLocalizationException equality', () {
    test('equal message and type are equal with equal hash codes', () {
      final a = VerificationLocalizationException.missingLanguage(
        language: 'de',
        sourceName: 'general',
      );
      final b = VerificationLocalizationException.missingLanguage(
        language: 'de',
        sourceName: 'general',
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different sourceName makes exceptions not equal', () {
      final a = VerificationLocalizationException.missingLanguage(
        language: 'de',
        sourceName: 'general',
      );
      final b = VerificationLocalizationException.missingLanguage(
        language: 'de',
        sourceName: 'feature_a',
      );

      expect(a, isNot(equals(b)));
    });
  });
}
