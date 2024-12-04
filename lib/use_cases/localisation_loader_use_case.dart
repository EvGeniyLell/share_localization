import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/utils/common.dart';
import 'package:share_localisation/utils/json_data.dart';

class LocalisationLoaderUseCase {
  const LocalisationLoaderUseCase();

  AppTask<LocalisationDto> call(String filepath) {
    return runAppTaskSafely(() async {
      final data = buildData(filepath);
      return buildDto(data);
    });
  }

  @visibleForTesting
  JsonData buildData(String filepath) {
    final content = File(filepath).readAsStringSync();
    final map = json.decode(content);
    if (map is! JsonMap) {
      throw JsonDataError('Wrong json map at $filepath');
    }
    return JsonData(filepath, map);
  }

  @visibleForTesting
  LocalisationDto buildDto(JsonData data) {
    return LocalisationDto(
      languages: buildLanguages(data.getSubList('languages')),
      keys: buildKeys(data.getSub('keys').groupByKeys()),
    );
  }

  @visibleForTesting
  List<LocalisationKeyDto> buildKeys(List<JsonData> list) {
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
  List<LocalisationKeyArgumentDto> buildKeyArguments(List<JsonData> list) {
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
  List<LocalisationKeyTranslationDto> buildKeyTranslations(List<JsonData> list) {
    return list.map((data) {
      print(data.map);
      return LocalisationKeyTranslationDto(
        key: data.get('key'),
        message: data.get('root'),
      );
    }).toList();
  }

  @visibleForTesting
  List<LanguageDto> buildLanguages(List<JsonData> list) {
    return list.map((data) {
      print(data.map);
      return LanguageDto(
        abbreviation: data.get('root'),
      );
    }).toList();
  }
}

