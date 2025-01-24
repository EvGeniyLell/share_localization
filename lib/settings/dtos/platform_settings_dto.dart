import 'package:meta/meta.dart';
import 'package:share_localization/settings/dtos/settings_language_dto.dart';
import 'package:share_localization/settings/dtos/platform_options_dto.dart';
import 'package:share_localization/settings/dtos/settings_dto.dart';

typedef IosSettingsDto = PlatformSettingsDto<IosOptionsDto>;
typedef AndroidSettingsDto = PlatformSettingsDto<AndroidOptionsDto>;
typedef FlutterSettingsDto = PlatformSettingsDto<FlutterOptionsDto>;

@immutable
class PlatformSettingsDto<PlatformOptionsDto> {
  final List<SettingsLanguageDto> languages;
  final String sourcesFolder;

  final PlatformOptionsDto options;

  PlatformSettingsDto({
    required SettingsDto settings,
    required this.options,
  })  : languages = settings.languages,
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
    final PlatformOptionsDto? options = switch (T) {
      IosOptionsDto _ => ios,
      AndroidOptionsDto _ => android,
      FlutterOptionsDto _ => flutter,
      _ => null,
    };
    if (options == null) {
      return null;
    }
    return PlatformSettingsDto<T>(
      settings: this,
      options: options as T,
    );
  }
}
