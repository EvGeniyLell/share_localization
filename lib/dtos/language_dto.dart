class LanguageDto {
  final String abbreviation;

  const LanguageDto({
    required this.abbreviation,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageDto &&
          runtimeType == other.runtimeType &&
          abbreviation == other.abbreviation;

  @override
  int get hashCode => abbreviation.hashCode;

  @override
  toString() {
    return '$LanguageDto(abbreviation: $abbreviation)';
  }

}
