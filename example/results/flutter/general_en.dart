import 'general.dart';

// ignore_for_file: type=lint

/// The translations for En.
class GeneralEn extends General {
  GeneralEn([String locale = 'en']) : super(locale);

  @override
  String fileSizeErrorBody(String fileName, double currentSize, double maximumSize) => 'The $file_name has size $current_size, it is biggest then maximum $maximum_size.';
      
  @override
  String fileSizeAttention(int maximumSize) => 'File should be less or equal to $maximum_size MB.';
      
  @override
  String get fileSizeTitle => 'Attention! The file size is too big.';
      
}
