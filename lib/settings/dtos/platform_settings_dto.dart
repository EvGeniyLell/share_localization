import 'package:meta/meta.dart';
import 'package:share_localization/settings/dtos/platform_options_dto.dart';
import 'package:share_localization/settings/dtos/settings_dto.dart';
import 'package:share_localization/settings/dtos/settings_language_dto.dart';

typedef IosSettingsDto = PlatformSettingsDto<IosOptionsDto>;
typedef AndroidSettingsDto = PlatformSettingsDto<AndroidOptionsDto>;
typedef FlutterSettingsDto = PlatformSettingsDto<FlutterOptionsDto>;

@immutable
class PlatformSettingsDto<Options extends PlatformOptionsDto> {
  final List<SettingsLanguageDto> languages;
  final String sourcesFolder;

  final Options options;

  PlatformSettingsDto({required SettingsDto settings, required this.options})
    : languages = settings.languages,
      sourcesFolder = settings.sourcesFolder;

  @override
  String toString() {
    return '$SettingsDto('
        'languages: $languages, '
        'sourcesFolder: $sourcesFolder, '
        'options: $options'
        ')';
  }
}

extension PlatformSettingsDtoHelperExtension on SettingsDto {
  PlatformSettingsDto<T>?
  toPlatformSettingsDto<T extends PlatformOptionsDto>() {
    final PlatformOptionsDto? options;
    if (T == IosOptionsDto) {
      options = ios;
    } else if (T == AndroidOptionsDto) {
      options = android;
    } else if (T == FlutterOptionsDto) {
      options = flutter;
    } else {
      options = null;
    }
    if (options == null) {
      return null;
    }
    return PlatformSettingsDto<T>(settings: this, options: options as T);
  }
}
