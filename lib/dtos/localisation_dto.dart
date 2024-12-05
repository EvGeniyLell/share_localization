import 'package:share_localisation/utils/common.dart';

import 'language_dto.dart';
import 'localisation_key_dto.dart';

class LocalisationDto {
  final String name;
  final List<LanguageDto> languages;
  final List<LocalisationKeyDto> keys;

  const LocalisationDto({
    required this.name,
    required this.languages,
    required this.keys,
  });

  LocalisationDto copyWith({
    String? name,
    List<LanguageDto>? languages,
    List<LocalisationKeyDto>? keys,
  }) {
    return LocalisationDto(
      name: name ?? this.name,
      languages: languages ?? this.languages,
      keys: keys ?? this.keys,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalisationDto &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          languages.equals(other.languages) &&
          keys.equals(other.keys);

  @override
  int get hashCode => name.hashCode ^ languages.hashCode ^ keys.hashCode;

  @override
  String toString() {
    return '$LocalisationDto(name: $name, languages: $languages, keys: $keys)';
  }
}
