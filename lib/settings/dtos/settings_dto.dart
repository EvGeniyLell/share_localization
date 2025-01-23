import 'package:meta/meta.dart';
import 'package:share_localization/settings/dtos/language_dto.dart';
import 'package:share_localization/settings/dtos/platform_options_dto.dart';

@immutable
class SettingsDto {
  final List<LanguageDto> languages;
  final String sourcesFolder;
  final IosOptionsDto? ios;
  final AndroidOptionsDto? android;
  final FlutterOptionsDto? flutter;

  const SettingsDto({
    required this.languages,
    required this.sourcesFolder,
    required this.ios,
    required this.android,
    required this.flutter,
  });

  SettingsDto copyWith({
    List<LanguageDto>? languages,
    String? sourcesFolder,
    IosOptionsDto? ios,
    AndroidOptionsDto? android,
    FlutterOptionsDto? flutter,
  }) {
    return SettingsDto(
      languages: languages ?? this.languages,
      sourcesFolder: sourcesFolder ?? this.sourcesFolder,
      ios: ios ?? this.ios,
      android: android ?? this.android,
      flutter: flutter ?? this.flutter,
    );
  }

  @override
  String toString() {
    return '$SettingsDto(languages: $languages, sourcesFolder: $sourcesFolder)';
  }
}
