import 'general_localization.dart';

// ignore_for_file: type=lint

/// The translations for En.
class GeneralLocalizationEn extends GeneralLocalization {
  GeneralLocalizationEn([String locale = 'en']) : super(locale);

  @override
  String fileSizeErrorBody(String fileName, double currentSize, double maximumSize) => 'The $fileName has size $currentSize, it is biggest then maximum $maximumSize.';
      
  @override
  String fileSizeAttention(int maximumSize) => 'File should be less or equal to $maximumSize MB.';
      
  @override
  String get fileSizeTitle => 'Attention! The file size is too big.';

  @override
  String get escapeTest => 'Couldn\'t!\n Test.';

}
