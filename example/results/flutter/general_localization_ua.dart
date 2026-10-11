import 'general_localization.dart';

// ignore_for_file: type=lint

/// The translations for Ua.
class GeneralLocalizationUa extends GeneralLocalization {
  GeneralLocalizationUa([String locale = 'ua']) : super(locale);

  @override
  String fileSizeErrorBody(String fileName, double currentSize, double maximumSize) => 'Цей $fileName має розмір $currentSize, це більш ніж дозволений максимум $maximumSize.';
      
  @override
  String fileSizeAttention(int maximumSize) => 'Файл повинен бути меншим або рівним $maximumSize МБ.';
      
  @override
  String get fileSizeTitle => 'Увага! Розмір файлу занадто великий.';

  @override
  String get escapeTest => 'Ім\'я!\n Test.';

}
