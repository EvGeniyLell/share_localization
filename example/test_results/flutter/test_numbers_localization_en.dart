import 'test_numbers_localization.dart';

// ignore_for_file: type=lint

/// The translations for En.
class TestNumbersLocalizationEn extends TestNumbersLocalization {
  TestNumbersLocalizationEn([String locale = 'en']) : super(locale);

  @override
  String fileReport(String title, double size, int pages) => 'File $title has $pages pages and weighs $size MB';

}
