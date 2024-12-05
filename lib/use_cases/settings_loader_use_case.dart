import 'package:meta/meta.dart';
import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/utils/common.dart';
import 'package:share_localisation/utils/json_data.dart';

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
  R buildDto<R>(JsonData data) {
    final builder = <Type, Function>{
      SettingsDto: buildSettingsDto,
      IosSettingsDto: buildIosSettingsDto,
      AndroidSettingsDto: buildAndroidSettingsDto,
      FlutterSettingsDto: buildFlutterSettingsDto,
      LanguageDto: buildLanguageDto,
    }[R];
    if (builder == null) {
      throw UnimplementedError('Type $R is not implemented');
    }
    return builder(data) as R;
  }

  SettingsDto buildSettingsDto(JsonData data) {
    return SettingsDto(
      languages: data.getSubList('languages').dtos(),
      sourcesFolder: data.get('sources_folder'),
      ios: data.getSub('ios').dto(),
      android: data.getSub('android').dto(),
      flutter: data.getSub('flutter').dto(),
    );
  }

  IosSettingsDto buildIosSettingsDto(JsonData data) {
    return IosSettingsDto(
      destinationFolder: data.get('destination_folder'),
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
      abbreviation: data.get('root'),
    );
  }
}
