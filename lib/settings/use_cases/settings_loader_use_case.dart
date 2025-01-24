import 'package:meta/meta.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/settings/dtos/settings_language_dto.dart';
import 'package:share_localization/settings/dtos/platform_options_dto.dart';
import 'package:share_localization/settings/dtos/settings_dto.dart';

/// A use case for loading settings from a file.
///
/// This class provides functionality to load settings
/// from a specified file path.
/// It uses the [JsonData] utility to read the file
/// and convert its contents into appropriate DTOs.
class SettingsLoaderUseCase {
  const SettingsLoaderUseCase();

  Task<SettingsDto> call(String filepath) {
    return runAppTaskSafely(() async {
      final data = await JsonData.fromFile(filepath, buildDto: buildDto);
      return buildDto<SettingsDto>(data);
    });
  }
}

@visibleForTesting
extension SettingsLoaderUseCaseDtos on SettingsLoaderUseCase {
  /// This method uses a map of type to builder functions
  /// to convert the [JsonData] into the appropriate DTO type.
  ///
  /// If the type [R] is not implemented, it throws an [UnimplementedError].
  R buildDto<R extends Object>(JsonData data) {
    final map = <Type, Function>{
      SettingsDto: buildSettingsDto,
      IosOptionsDto: buildIosOptionsDto,
      AndroidOptionsDto: buildAndroidOptionsDto,
      FlutterOptionsDto: buildFlutterOptionsDto,
      SettingsLanguageDto: buildLanguageDto,
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

  IosOptionsDto buildIosOptionsDto(JsonData data) {
    return IosOptionsDto(
      destinationFolder: data.get('destination_folder'),
      bundleName: data.get('bundle_name'),
    );
  }

  AndroidOptionsDto buildAndroidOptionsDto(JsonData data) {
    return AndroidOptionsDto(
      useCamelCase: data.get('use_camel_case'),
      destinationFolder: data.get('destination_folder'),
    );
  }

  FlutterOptionsDto buildFlutterOptionsDto(JsonData data) {
    return FlutterOptionsDto(
      destinationFolder: data.get('destination_folder'),
    );
  }

  SettingsLanguageDto buildLanguageDto(JsonData data) {
    return SettingsLanguageDto(
      key: data.get('root'),
    );
  }
}
