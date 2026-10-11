import 'package:meta/meta.dart';
import 'package:share_localization/localizations/dtos/localization_key_argument_dto.dart';
import 'package:share_localization/localizations/dtos/localization_key_translation_dto.dart';
import 'package:share_localization/localizations/utils/list_equals_extension.dart';

@immutable
class LocalizationKeyDto {
  final String key;
  final String comment;
  final List<LocalizationKeyArgumentDto> arguments;
  final List<LocalizationKeyTranslationDto> translations;

  const LocalizationKeyDto({
    required this.key,
    required this.comment,
    required this.arguments,
    required this.translations,
  });

  LocalizationKeyDto copyWith({
    String? key,
    String? comment,
    List<LocalizationKeyArgumentDto>? arguments,
    List<LocalizationKeyTranslationDto>? translations,
  }) {
    return LocalizationKeyDto(
      key: key ?? this.key,
      comment: comment ?? this.comment,
      arguments: arguments ?? this.arguments,
      translations: translations ?? this.translations,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LocalizationKeyDto &&
            runtimeType == other.runtimeType &&
            key == other.key &&
            comment == other.comment &&
            arguments.equals(other.arguments) &&
            translations.equals(other.translations);
  }

  @override
  int get hashCode => Object.hash(
    key,
    comment,
    Object.hashAll(arguments),
    Object.hashAll(translations),
  );

  @override
  String toString() {
    return '$LocalizationKeyDto(key: $key, comment: $comment, '
        'arguments: $arguments, translations: $translations)';
  }
}
