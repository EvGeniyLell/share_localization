import 'package:meta/meta.dart';

@immutable
class LocalisationKeyArgumentDto {
  final String name;
  final LocalisationKeyDtoType type;

  const LocalisationKeyArgumentDto({
    required this.name,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalisationKeyArgumentDto &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type;

  @override
  int get hashCode => name.hashCode ^ type.hashCode;

  @override
  String toString() {
    return '$LocalisationKeyArgumentDto(name: $name, type: $type)';
  }
}

enum LocalisationKeyDtoType {
  string,
  int,
  double,
}
