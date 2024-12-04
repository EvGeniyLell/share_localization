import 'package:share_localisation/utils/json_data.dart';

class LocalisationKeyArgumentDto {
  final String name;
  final LocalisationKeyDtoType type;

  const LocalisationKeyArgumentDto({
    required this.name,
    required this.type,
  });

  factory LocalisationKeyArgumentDto.fromJsonData(JsonData data) {
    return LocalisationKeyArgumentDto(
      name: data.get('name'),
      type: data.get('type', transform: (String name) {
        return LocalisationKeyDtoType.values
            .firstWhere((e) => e.name.toLowerCase() == name.toLowerCase());
      }),
    );
  }

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
