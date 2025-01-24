import 'package:meta/meta.dart';

@immutable
class SettingsLanguageDto {
  final String key;

  const SettingsLanguageDto({
    required this.key,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsLanguageDto &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return '$SettingsLanguageDto(abbreviation: $key)';
  }
}
