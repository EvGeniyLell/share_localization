import 'package:meta/meta.dart';

@immutable
class LocalizationKeyTranslationDto {
  /// Key of language.
  final String languageKey;

  /// Translated message.
  final String message;

  const LocalizationKeyTranslationDto({
    required this.languageKey,
    required this.message,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizationKeyTranslationDto &&
          runtimeType == other.runtimeType &&
          languageKey == other.languageKey &&
          message == other.message;

  @override
  int get hashCode => languageKey.hashCode ^ message.hashCode;

  @override
  String toString() {
    return '$LocalizationKeyTranslationDto'
        '(key: $languageKey, message: $message)';
  }
}
