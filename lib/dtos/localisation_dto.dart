import 'package:share_localisation/utils/common.dart';

import 'language_dto.dart';
import 'localisation_key_dto.dart';

class LocalisationDto {
  final List<LanguageDto> languages;
  final List<LocalisationKeyDto> keys;

  LocalisationDto({
    required this.languages,
    required this.keys,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalisationDto &&
          runtimeType == other.runtimeType &&
          languages.equals(other.languages) &&
          keys.equals(other.keys);

  @override
  int get hashCode => languages.hashCode ^ keys.hashCode;

  @override
  String toString() {
    return '$LocalisationDto(languages: $languages, keys: $keys)';
  }
}
