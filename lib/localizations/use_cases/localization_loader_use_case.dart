import 'package:meta/meta.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/dtos/language_dto.dart';
import 'package:share_localization/localizations/dtos/localization_dto.dart';
import 'package:share_localization/localizations/dtos/localization_key_argument_dto.dart';
import 'package:share_localization/localizations/dtos/localization_key_dto.dart';
import 'package:share_localization/localizations/dtos/localization_key_translation_dto.dart';

class LocalizationLoaderUseCase {
  const LocalizationLoaderUseCase();

  Task<LocalizationDto> call(String filepath) {
    return runAppTaskSafely(() async {
      final data = await JsonData.fromFile(filepath, buildDto: buildDto);
      return buildDto<LocalizationDto>(data);
    });
  }
}

@visibleForTesting
extension LocalizationLoaderUseCaseDtos on LocalizationLoaderUseCase {
  R buildDto<R extends Object>(JsonData data) {
    final builder = <Type, Function>{
      LocalizationDto: buildLocalizationDto,
      LocalizationKeyDto: buildKeyDto,
      LocalizationKeyArgumentDto: buildKeyArgumentDto,
      LocalizationKeyTranslationDto: buildKeyTranslationDto,
      LanguageDto: buildLanguageDto,
    }[R];
    if (builder == null) {
      throw UnimplementedError('Type $R is not implemented');
    }
    return builder(data) as R;
  }

  LocalizationDto buildLocalizationDto(JsonData data) {
    return LocalizationDto(
      name: data.filepath.split('/').last,
      languages: data.getSubList('languages').dtos(),
      keys: data.getSub('keys').groupByKeys().dtos(),
    );
  }

  LocalizationKeyDto buildKeyDto(JsonData data) {
    return LocalizationKeyDto(
      key: data.get('key'),
      comment: data.get('comment'),
      arguments: data.getSubList('arguments', defaultValue: []).dtos(),
      translation:
          data.getSub('localizations', defaultValue: []).groupByKeys().dtos(),
    );
  }

  LocalizationKeyArgumentDto buildKeyArgumentDto(JsonData data) {
    final String typeName = data.get('type');
    try {
      return LocalizationKeyArgumentDto(
        name: data.get('name'),
        type: LocalizationKeyDtoType.values
            .firstWhere((e) => e.name.toLowerCase() == typeName.toLowerCase()),
      );
    } on Object catch (e) {
      throw UnexpectedException(
        'Unknown type $typeName: $e, use one of '
        '${LocalizationKeyDtoType.values.map((e) => e.name).join(', ')}',
      );
    }
  }

  LocalizationKeyTranslationDto buildKeyTranslationDto(JsonData data) {
    return LocalizationKeyTranslationDto(
      languageKey: data.get('key'),
      message: data.get('root'),
    );
  }

  LanguageDto buildLanguageDto(JsonData data) {
    return LanguageDto(
      key: data.get('root'),
    );
  }
}
