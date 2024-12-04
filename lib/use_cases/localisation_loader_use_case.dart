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
      return data.getLocalisationDto();
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
}

@visibleForTesting
extension JsonDataBuildDtos on List<JsonData> {
  List<R> dtos<R>() => map((data) => data.dto<R>()).toList();
}

@visibleForTesting
extension JsonDataBuildDto on JsonData {
  R dto<R>() {
    if (R == LocalisationKeyDto) {
      return getKeyDto() as R;
    }
    if (R == LocalisationKeyArgumentDto) {
      return getKeyArgumentDto() as R;
    }
    if (R == LocalisationKeyTranslationDto) {
      return getKeyTranslationDto() as R;
    }
    if (R == LanguageDto) {
      return getLanguageDto() as R;
    }
    throw UnimplementedError('Type $R is not implemented');
  }

  LocalisationDto getLocalisationDto() {
    return LocalisationDto(
      languages: getSubList('languages').dtos(),
      keys: getSub('keys').groupByKeys().dtos(),
    );
  }

  LocalisationKeyDto getKeyDto() {
    return LocalisationKeyDto(
      key: get('key'),
      comment: get('comment'),
      arguments: getSubList('arguments', defaultValue: []).dtos(),
      localizations:
          getSub('localizations', defaultValue: []).groupByKeys().dtos(),
    );
  }

  LocalisationKeyArgumentDto getKeyArgumentDto() {
    final String typeName = get('type');
    return LocalisationKeyArgumentDto(
      name: get('name'),
      type: LocalisationKeyDtoType.values
          .firstWhere((e) => e.name.toLowerCase() == typeName.toLowerCase()),
    );
  }

  LocalisationKeyTranslationDto getKeyTranslationDto() {
    return LocalisationKeyTranslationDto(
      key: get('key'),
      message: get('root'),
    );
  }

  LanguageDto getLanguageDto() {
    return LanguageDto(
      abbreviation: get('root'),
    );
  }
}
