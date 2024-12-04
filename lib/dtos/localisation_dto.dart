import 'package:share_localisation/utils/json_data.dart';

import 'language_dto.dart';
import 'localisation_key_dto.dart';

class LocalisationDto {
  final List<LanguageDto> languages;
  final List<LocalisationKeyDto> keys;

  LocalisationDto({
    required this.languages,
    required this.keys,
  });

  factory LocalisationDto.fromJsonData(JsonData data) {
    return LocalisationDto(
      languages: data.getMapList(
        'languages',
        transform: LanguageDto.fromJsonData,
      ),
      keys: data.getMapWithKeys(
        'keys',
        transform: LocalisationKeyDto.fromJsonData,
      ),
    );
  }
}
