import 'package:share_localization/code_generation/build_report.dart';
import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';
import 'package:test/test.dart';

void main() {
  group('BuildReport', () {
    test('collapses equal build warnings into one', () {
      final report = BuildReport([
        const BuildLocalizationException.missingIosSettings(),
        const BuildLocalizationException.missingIosSettings(),
      ]);

      expect(report.warnings, hasLength(1));
      expect(
        report.warnings.single,
        const BuildLocalizationException.missingIosSettings(),
      );
    });

    test('keeps build warnings with different messages', () {
      final report = BuildReport([
        const BuildLocalizationException.missingIosSettings(),
        const BuildLocalizationException.missingIosSettings('other'),
      ]);

      expect(report.warnings, hasLength(2));
    });

    test('keeps the first-seen order of warnings', () {
      const android = BuildLocalizationException.missingAndroidSettings();
      const ios = BuildLocalizationException.missingIosSettings();
      const flutter = BuildLocalizationException.missingFlutterSettings();

      final report = BuildReport([android, ios, android, flutter, ios]);

      expect(report.warnings, [android, ios, flutter]);
    });

    test('collapses equal verification warnings', () {
      final report = BuildReport([
        VerificationLocalizationException.missingLanguage(
          language: 'de',
          sourceName: 'general',
        ),
        VerificationLocalizationException.missingLanguage(
          language: 'de',
          sourceName: 'general',
        ),
      ]);

      expect(report.warnings, hasLength(1));
    });

    test('keeps verification warnings from different sources', () {
      final report = BuildReport([
        VerificationLocalizationException.missingLanguage(
          language: 'de',
          sourceName: 'general',
        ),
        VerificationLocalizationException.missingLanguage(
          language: 'de',
          sourceName: 'feature_a',
        ),
      ]);

      expect(report.warnings, hasLength(2));
    });

    test('does not collapse duplicated errors', () {
      final error = UnexpectedException('builder failed');
      final report = BuildReport([error, error]);

      expect(report.errors, hasLength(2));
      expect(report.hasErrors, isTrue);
      expect(report.warnings, isEmpty);
    });
  });
}
