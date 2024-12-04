import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

typedef JsonMap = Map<String, Object?>;

class JsonData {
  static const String _rootKey = '#ROOT#';
  @visibleForTesting
  final String source;
  @visibleForTesting
  final List<JsonMap> list;
  @visibleForTesting
  final String path;

  JsonData(this.source, this.list, {required this.path});

  factory JsonData.filepath(String filepath) {
    final content = File(filepath).readAsStringSync();
    final data = json.decode(content);
    if (data is JsonMap) {
      return JsonData(filepath, [data], path: 'root');
    }
    if (data is List<JsonMap>) {
      return JsonData(filepath, data, path: 'root');
    }

    throw ArgumentError('Wrong json map at $filepath');
  }

  @override
  String toString() {
    return '$JsonData: $source:$path';
  }

  JsonMap get map {
    if (list.length != 1) {
      throw ArgumentError('List should have only one element');
    }
    return list.first;
  }

  R _safetyMap<R, V>(String? key, R Function(V) block) {
    try {
      print('### $key -> ${map[key ?? _rootKey]}');
      final value = map[key ?? _rootKey] as V;
      final result = block(value);
      return result;
    } on Object catch (error) {
      throw ArgumentError(
        '$error\nWhere key ${key ?? _rootKey} ($R) is failed at $this',
      );
    }
  }

  R get<R, V>(String? key, {R Function(V)? transform}) {
    final resolvedTransform = transform ?? (v) => v as R;
    return _safetyMap<R, V>(key, resolvedTransform);
  }

  List<R> getList<R, V>(String? key, {R Function(V)? transform}) {
    final resolvedTransform = transform ?? (v) => v as R;
    return _safetyMap<List<R>, List<V>>(key, (list) {
      return list.map(resolvedTransform).toList();
    });
  }

  R _subJsonData<R>(
    Object? subData,
    String? key,
    int? index,
    R Function(JsonData) transform,
  ) {
    final newPath =
        '$path/${key ?? _rootKey}${index != null ? '[$index]' : ''}';
    if (subData is! JsonMap) {
      if (subData is! List<JsonMap>) {
        final map = JsonMap();
        map[_rootKey] = subData;
        final newData = JsonData(source, [map], path: newPath);
        print('>>>1 $newData ($subData)');
        return transform(newData);
      } else {
        final newData = JsonData(source, subData, path: newPath);
        print('>>>2 $newData ($subData)');
        return transform(newData);
      }
    } else {
      final newData = JsonData(source, [subData], path: newPath);
      print('>>>3 $newData ($subData)');
      return transform(newData);
    }
  }

  R getMap<R, V>(
    String? key, {
    required R Function(JsonData) transform,
  }) {
    return _safetyMap<R, V>(key, (subData) {
      return _subJsonData(subData, key, null, transform);
    });
  }

  List<R> getMapList<R, V>(
    String? key, {
    required R Function(JsonData) transform,
    Object? defaultValue,
  }) {
    if (map[key ?? _rootKey] == null) {
      map[key ?? _rootKey] = defaultValue;
    }
    return _safetyMap<List<R>, List<V>>(key, (list) {
      var index = 0;
      return list.map((subData) {
        index += 1;
        return _subJsonData(subData, key, index, transform);
      }).toList();
    });
  }

  List<R> getMapWithKeys<R, V>(
    String? key, {
    required R Function(JsonData) transform,
  }) {
    return getMap(key, transform: (data) {
      return data.map.keys.map((key) {
        return data.getMap(key, transform: (data) {
          data.map['key'] = key;
          return transform(data);
        });
      }).toList();
    });
  }
}
