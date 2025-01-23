import 'package:meta/meta.dart';
import 'package:share_localization/localizations/dtos/language_dto.dart';
import 'package:share_localization/localizations/dtos/localization_key_dto.dart';
import 'package:share_localization/localizations/utils/list_equals_extension.dart';

@immutable
class LocalizationDto {
  final String name;
  final List<LanguageDto> languages;
  final List<LocalizationKeyDto> keys;

  const LocalizationDto({
    required this.name,
    required this.languages,
    required this.keys,
  });

  LocalizationDto copyWith({
    String? name,
    List<LanguageDto>? languages,
    List<LocalizationKeyDto>? keys,
  }) {
    return LocalizationDto(
      name: name ?? this.name,
      languages: languages ?? this.languages,
      keys: keys ?? this.keys,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizationDto &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          languages.equals(other.languages) &&
          keys.equals(other.keys);

  @override
  int get hashCode => name.hashCode ^ languages.hashCode ^ keys.hashCode;

  @override
  String toString() {
    return '$LocalizationDto(name: $name, languages: $languages, keys: $keys)';
  }
}
