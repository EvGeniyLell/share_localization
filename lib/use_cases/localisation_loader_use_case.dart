import 'package:meta/meta.dart';
import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/utils/common.dart';
import 'package:share_localisation/utils/json_data.dart';

class LocalisationLoaderUseCase {
  const LocalisationLoaderUseCase();

  AppTask<LocalisationDto> call(String filepath) {
    return runAppTaskSafely(() async {
      final data = await JsonData.fromFile(filepath, buildDto: buildDto);
      return buildDto<LocalisationDto>(data);
    });
  }
}

@visibleForTesting
extension LocalisationLoaderUseCaseDtos on LocalisationLoaderUseCase {
  R buildDto<R>(JsonData data) {
    final builder = <Type, Function>{
      LocalisationDto: buildLocalisationDto,
      LocalisationKeyDto: buildKeyDto,
      LocalisationKeyArgumentDto: buildKeyArgumentDto,
      LocalisationKeyTranslationDto: buildKeyTranslationDto,
      LanguageDto: buildLanguageDto,
    }[R];
    if (builder == null) {
      throw UnimplementedError('Type $R is not implemented');
    }
    return builder(data) as R;
  }

  LocalisationDto buildLocalisationDto(JsonData data) {
    return LocalisationDto(
      name: data.filepath.split('/').last,
      languages: data.getSubList('languages').dtos(),
      keys: data.getSub('keys').groupByKeys().dtos(),
    );
  }

  LocalisationKeyDto buildKeyDto(JsonData data) {
    return LocalisationKeyDto(
      key: data.get('key'),
      comment: data.get('comment'),
      arguments: data.getSubList('arguments', defaultValue: []).dtos(),
      localizations:
          data.getSub('localizations', defaultValue: []).groupByKeys().dtos(),
    );
  }

  LocalisationKeyArgumentDto buildKeyArgumentDto(JsonData data) {
    final String typeName = data.get('type');
    return LocalisationKeyArgumentDto(
      name: data.get('name'),
      type: LocalisationKeyDtoType.values
          .firstWhere((e) => e.name.toLowerCase() == typeName.toLowerCase()),
    );
  }

  LocalisationKeyTranslationDto buildKeyTranslationDto(JsonData data) {
    return LocalisationKeyTranslationDto(
      key: data.get('key'),
      message: data.get('root'),
    );
  }

  LanguageDto buildLanguageDto(JsonData data) {
    return LanguageDto(
      abbreviation: data.get('root'),
    );
  }
}
