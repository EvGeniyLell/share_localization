import 'package:meta/meta.dart';

@immutable
class LocalisationKeyTranslationDto {
  /// Key of language.
  final String languageKey;

  /// Translated message.
  final String message;

  const LocalisationKeyTranslationDto({
    required this.languageKey,
    required this.message,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalisationKeyTranslationDto &&
          runtimeType == other.runtimeType &&
          languageKey == other.languageKey &&
          message == other.message;

  @override
  int get hashCode => languageKey.hashCode ^ message.hashCode;

  @override
  String toString() {
    return '$LocalisationKeyTranslationDto'
        '(key: $languageKey, message: $message)';
  }
}
