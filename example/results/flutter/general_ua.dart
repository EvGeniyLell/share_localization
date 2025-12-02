import 'general.dart';

// ignore_for_file: type=lint

/// The translations for Ua.
class GeneralUa extends General {
  GeneralUa([String locale = 'ua']) : super(locale);

  @override
  String fileSizeErrorBody(String fileName, double currentSize, double maximumSize) => 'Цей $file_name має розмір $current_size, це більш ніж дозволений максимум $maximum_size.';
      
  @override
  String fileSizeAttention(int maximumSize) => 'Файл повинен бути меншим або рівним $maximum_size МБ.';
      
  @override
  String get fileSizeTitle => 'Увага! Розмір файлу занадто великий.';

  @override
  String get escapeTest => 'Ім\'я!\n Test.';

}
