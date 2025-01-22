import 'package:meta/meta.dart';
import 'package:share_localization/dtos/dtos.dart';
import 'package:share_localization/utils/common.dart';
import 'package:share_localization/utils/json_data.dart';

class SettingsLoaderUseCase {
  const SettingsLoaderUseCase();

  AppTask<SettingsDto> call(String filepath) {
    return runAppTaskSafely(() async {
      final data = await JsonData.fromFile(filepath, buildDto: buildDto);
      return buildDto<SettingsDto>(data);
    });
  }
}

@visibleForTesting
extension SettingsLoaderUseCaseDtos on SettingsLoaderUseCase {
  R buildDto<R extends Object>(JsonData data) {
    final map = <Type, Function>{
      SettingsDto: buildSettingsDto,
      IosSettingsDto: buildIosSettingsDto,
      AndroidSettingsDto: buildAndroidSettingsDto,
      FlutterSettingsDto: buildFlutterSettingsDto,
      LanguageDto: buildLanguageDto,
    };
    final builder = map[R];
    if (builder == null) {
      throw UnimplementedError('Type $R is not implemented');
    }
    return builder(data) as R;
  }

  SettingsDto buildSettingsDto(JsonData data) {
    return SettingsDto(
      languages: data.getSubList('languages').dtos(),
      sourcesFolder: data.get('sources_folder'),
      ios: data.getSub('ios').dtoOrNull(),
      android: data.getSub('android').dtoOrNull(),
      flutter: data.getSub('flutter').dtoOrNull(),
    );
  }

  IosSettingsDto buildIosSettingsDto(JsonData data) {
    return IosSettingsDto(
      destinationFolder: data.get('destination_folder'),
      bundleName: data.get('bundle_name'),
    );
  }

  AndroidSettingsDto buildAndroidSettingsDto(JsonData data) {
    return AndroidSettingsDto(
      destinationFolder: data.get('destination_folder'),
    );
  }

  FlutterSettingsDto buildFlutterSettingsDto(JsonData data) {
    return FlutterSettingsDto(
      destinationFolder: data.get('destination_folder'),
    );
  }

  LanguageDto buildLanguageDto(JsonData data) {
    return LanguageDto(
      key: data.get('root'),
    );
  }
}
