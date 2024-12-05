import 'package:share_localisation/utils/common.dart';

import 'localisation_key_argument_dto.dart';
import 'localisation_key_translation_dto.dart';

class LocalisationKeyDto {
  final String key;
  final String comment;
  final List<LocalisationKeyArgumentDto> arguments;
  final List<LocalisationKeyTranslationDto> translation;

  const LocalisationKeyDto({
    required this.key,
    required this.comment,
    required this.arguments,
    required this.translation,
  });

  LocalisationKeyDto copyWith({
    String? key,
    String? comment,
    List<LocalisationKeyArgumentDto>? arguments,
    List<LocalisationKeyTranslationDto>? translation,
  }) {
    return LocalisationKeyDto(
      key: key ?? this.key,
      comment: comment ?? this.comment,
      arguments: arguments ?? this.arguments,
      translation: translation ?? this.translation,
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
            translation.equals(other.translation);
  }

  @override
  int get hashCode {
    return key.hashCode ^
        comment.hashCode ^
        arguments.hashCode ^
        translation.hashCode;
  }

  @override
  String toString() {
    return '$LocalisationKeyDto(key: $key, comment: $comment, '
        'arguments: $arguments, localizations: $translation)';
  }
}
