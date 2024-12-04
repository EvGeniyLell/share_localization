import 'package:share_localisation/utils/common.dart';

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
