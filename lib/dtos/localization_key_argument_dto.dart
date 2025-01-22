import 'package:meta/meta.dart';

@immutable
class LocalizationKeyArgumentDto {
  final String name;
  final LocalizationKeyDtoType type;

  const LocalizationKeyArgumentDto({
    required this.name,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizationKeyArgumentDto &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type;

  @override
  int get hashCode => name.hashCode ^ type.hashCode;

  @override
  String toString() {
    return '$LocalizationKeyArgumentDto(name: $name, type: $type)';
  }
}

enum LocalizationKeyDtoType {
  string,
  int,
  double,
}
