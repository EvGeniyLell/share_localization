class LocalisationKeyTranslationDto {
  final String key;
  final String message;

  const LocalisationKeyTranslationDto({
    required this.key,
    required this.message,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalisationKeyTranslationDto &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          message == other.message;

  @override
  int get hashCode => key.hashCode ^ message.hashCode;

  @override
  String toString() {
    return '$LocalisationKeyTranslationDto(key: $key, message: $message)';
  }
}
