import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:share_localisation/dtos/language_dto.dart';
import 'package:share_localisation/dtos/localisation_dto.dart';
import 'package:share_localisation/dtos/localisation_key_argument_dto.dart';
import 'package:share_localisation/dtos/localisation_key_dto.dart';
import 'package:share_localisation/dtos/localisation_key_translation_dto.dart';
import 'package:share_localisation/utils/common.dart';
import 'package:share_localisation/utils/json_data.dart';

class LocalisationLoader {
  const LocalisationLoader();

  AppTask<LocalisationDto> call(String filepath) {
    return runAppTaskSafely(() async {
      final data = buildData(filepath);
      return buildDto(data);
    });
  }

  @visibleForTesting
  Data buildData(String filepath) {
    final content = File(filepath).readAsStringSync();
    final map = json.decode(content);
    if (map is! JsonMap) {
      throw DataError('Wrong json map at $filepath');
    }
    return Data(filepath, map);
  }

  @visibleForTesting
  LocalisationDto buildDto(Data data) {
    return LocalisationDto(
      languages: buildLanguages(data.getSubList('languages')),
      keys: buildKeys(data.getSub('keys').groupByKeys()),
    );
  }

  @visibleForTesting
  List<LocalisationKeyDto> buildKeys(List<Data> list) {
    return list.map((data) {
      return LocalisationKeyDto(
        key: data.get('key'),
        comment: data.get('comment'),
        arguments: buildKeyArguments(
          data.getSubList('arguments', defaultValue: []),
        ),
        localizations: buildKeyTranslations(
          data.getSub('localizations', defaultValue: []).groupByKeys(),
        ),
      );
    }).toList();
  }

  @visibleForTesting
  List<LocalisationKeyArgumentDto> buildKeyArguments(List<Data> list) {
    return list.map((data) {
      final String typeName = data.get('type');
      return LocalisationKeyArgumentDto(
        name: data.get('name'),
        type: LocalisationKeyDtoType.values
            .firstWhere((e) => e.name.toLowerCase() == typeName.toLowerCase()),
      );
    }).toList();
  }

  @visibleForTesting
  List<LocalisationKeyTranslationDto> buildKeyTranslations(List<Data> list) {
    return list.map((data) {
      print(data.map);
      return LocalisationKeyTranslationDto(
        key: data.get('key'),
        message: data.get('root'),
      );
    }).toList();
  }

  @visibleForTesting
  List<LanguageDto> buildLanguages(List<Data> list) {
    return list.map((data) {
      print(data.map);
      return LanguageDto(
        abbreviation: data.get('root'),
      );
    }).toList();
  }
}

@visibleForTesting
class Data {
  static const String rootKey = 'root';

  final String filepath;
  final JsonMap map;
  final String route;

  const Data(this.filepath, this.map, [this.route = rootKey]);

  String _newRoute(String key, {int? index}) {
    return '$route/$key'
        '${index != null ? '[$index]' : ''}';
  }

  /// Get value from map by key and cast it to [R].
  /// Throws [DataError] if value is not of type [R].
  R get<R>(String key, {Object? defaultValue}) {
    final value = map[key] ?? defaultValue;
    if (value is! R) {
      if (R == JsonMap) {
        final map = JsonMap();
        map[rootKey] = value;
        return map as R;
      }
      throw DataError.wrongType(this, key: key, value: value, expectedType: R);
    }
    return value;
  }

  /// Get sub [Data] from map by key.
  Data getSub(String key, {int? index, Object? defaultValue}) {
    final value = get<JsonMap>(key, defaultValue: defaultValue);
    return Data(filepath, value, _newRoute(key, index: index));
  }

  /// Get sub [Data] list from map by key.
  List<Data> getSubList(String key, {int? index, Object? defaultValue}) {
    final value = get<List<Object?>>(key, defaultValue: defaultValue);
    int index = 0;
    return value.map((value) {
      try {
        return Data(filepath, value as JsonMap, _newRoute(key, index: index++));
      } catch (e) {
        final map = JsonMap();
        map[rootKey] = value;
        return Data(filepath, map, _newRoute(key, index: index++));
      }
    }).toList();
  }

  /// Get sub [Data] list from map and group them by fields.
  /// names fields extracted to result.
  List<Data> groupByKeys([String keyName = 'key']) {
    return map.keys.map((key) {
      final sub = getSub(key);
      sub.map[keyName] = key;
      return sub;
    }).toList();
  }

  @override
  toString() {
    return '$Data{route: $route, map: $map}';
  }
}

class DataError extends Error {
  final String message;
  final String? filepath;
  final String? route;

  DataError(this.message, {this.route, this.filepath});

  @visibleForTesting
  factory DataError.fromData(Data data, String message) {
    return DataError(message, route: data.route, filepath: data.filepath);
  }

  factory DataError.wrongType(
    Data data, {
    required String key,
    required Object? value,
    required Type expectedType,
  }) {
    return DataError.fromData(
      data,
      'Wrong type ${value.runtimeType} for key $key, expected $expectedType'
      ', but value is $value',
    );
  }

  @override
  toString() {
    return '$DataError: $message'
        '${route != null ? ' at $route' : ''}'
        '${filepath != null ? ' in $filepath' : ''}';
  }
}
