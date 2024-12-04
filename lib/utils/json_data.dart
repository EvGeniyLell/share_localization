import 'package:meta/meta.dart';
import 'package:share_localisation/utils/common.dart';

class JsonData {
  static const String rootKey = 'root';

  final String filepath;
  final JsonMap map;
  final String route;

  const JsonData(this.filepath, this.map, [this.route = rootKey]);

  String _newRoute(String key, {int? index}) {
    return '$route/$key'
        '${index != null ? '[$index]' : ''}';
  }

  /// Get value from map by key and cast it to [R].
  /// Throws [JsonDataError] if value is not of type [R].
  R get<R>(String key, {Object? defaultValue}) {
    final value = map[key] ?? defaultValue;
    if (value is! R) {
      if (R == JsonMap) {
        final map = JsonMap();
        map[rootKey] = value;
        return map as R;
      }
      throw JsonDataError.wrongType(this,
          key: key, value: value, expectedType: R);
    }
    return value;
  }

  /// Get sub [JsonData] from map by key.
  JsonData getSub(String key, {int? index, Object? defaultValue}) {
    final value = get<JsonMap>(key, defaultValue: defaultValue);
    return JsonData(filepath, value, _newRoute(key, index: index));
  }

  /// Get sub [JsonData] list from map by key.
  List<JsonData> getSubList(String key, {int? index, Object? defaultValue}) {
    final value = get<List<Object?>>(key, defaultValue: defaultValue);
    int index = 0;
    return value.map((value) {
      try {
        return JsonData(
            filepath, value as JsonMap, _newRoute(key, index: index++));
      } catch (e) {
        final map = JsonMap();
        map[rootKey] = value;
        return JsonData(filepath, map, _newRoute(key, index: index++));
      }
    }).toList();
  }

  /// Get sub [JsonData] list from map and group them by fields.
  /// names fields extracted to result.
  List<JsonData> groupByKeys([String keyName = 'key']) {
    return map.keys.map((key) {
      final sub = getSub(key);
      sub.map[keyName] = key;
      return sub;
    }).toList();
  }

  @override
  toString() {
    return '$JsonData{route: $route, map: $map}';
  }
}

class JsonDataError extends Error {
  final String message;
  final String? filepath;
  final String? route;

  JsonDataError(this.message, {this.route, this.filepath});

  factory JsonDataError.wrongType(
    JsonData data, {
    required String key,
    required Object? value,
    required Type expectedType,
  }) {
    return JsonDataError(
      'Wrong type ${value.runtimeType} for key $key, expected $expectedType'
      ', but value is $value',
      route: data.route,
      filepath: data.filepath,
    );
  }

  @override
  toString() {
    return '$JsonDataError: $message'
        '${route != null ? ' at $route' : ''}'
        '${filepath != null ? ' in $filepath' : ''}';
  }
}
