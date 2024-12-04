import 'package:share_localisation/utils/json_data.dart';
import 'package:share_localisation/utils/list_extension.dart';

import 'localisation_key_argument_dto.dart';
import 'localisation_key_translation_dto.dart';

class LocalisationKeyDto {
  final String key;
  final String comment;
  final List<LocalisationKeyArgumentDto> arguments;
  final List<LocalisationKeyTranslationDto> localizations;

  const LocalisationKeyDto({
    required this.key,
    required this.comment,
    required this.arguments,
    required this.localizations,
  });

  factory LocalisationKeyDto.fromJsonData(JsonData data) {
    return LocalisationKeyDto(
      key: data.get('key'),
      comment: data.get('comment'),
      arguments: data.getMapList('arguments', transform: (data) {
        return LocalisationKeyArgumentDto.fromJsonData(data);
      }, defaultValue: []),
      localizations: data.getMapWithKeys('localizations', transform: (data) {
        return LocalisationKeyTranslationDto.fromJsonData(data);
      }),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LocalisationKeyDto &&
            runtimeType == other.runtimeType &&
            key == other.key &&
            comment == other.comment &&
            arguments.equals(other.arguments) &&
            localizations.equals(other.localizations);
  }

  @override
  int get hashCode {
    return key.hashCode ^
        comment.hashCode ^
        arguments.hashCode ^
        localizations.hashCode;
  }

  @override
  String toString() {
    return '$LocalisationKeyDto(key: $key, comment: $comment, '
        'arguments: $arguments, localizations: $localizations)';
  }
}
