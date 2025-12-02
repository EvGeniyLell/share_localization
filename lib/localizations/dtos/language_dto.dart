import 'package:meta/meta.dart';

@immutable
class LanguageDto {
  final String key;

  const LanguageDto({required this.key});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageDto &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return '$LanguageDto(abbreviation: $key)';
  }
}
