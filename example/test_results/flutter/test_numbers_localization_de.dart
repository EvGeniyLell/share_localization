import 'test_numbers_localization.dart';

// ignore_for_file: type=lint

/// The translations for De.
class TestNumbersLocalizationDe extends TestNumbersLocalization {
  TestNumbersLocalizationDe([String locale = 'de']) : super(locale);

  @override
  String fileReport(String title, double size, int pages) => 'Datei $title hat $pages Seiten und wiegt $size MB';

}
