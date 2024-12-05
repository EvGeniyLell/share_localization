import 'package:share_localisation/dtos/language_dto.dart';

class SettingsDto {
  final List<LanguageDto> languages;
  final String sourcesFolder;
  final IosSettingsDto ios;
  final AndroidSettingsDto android;
  final FlutterSettingsDto flutter;

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
    IosSettingsDto? ios,
    AndroidSettingsDto? android,
    FlutterSettingsDto? flutter,
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

abstract class PlatformSettingsDto {
  final String destinationFolder;

  const PlatformSettingsDto({
    required this.destinationFolder,
  });
}

class IosSettingsDto extends PlatformSettingsDto {
  const IosSettingsDto({
    required super.destinationFolder,
  });
}

class AndroidSettingsDto extends PlatformSettingsDto {
  const AndroidSettingsDto({
    required super.destinationFolder,
  });
}

class FlutterSettingsDto extends PlatformSettingsDto {
  const FlutterSettingsDto({
    required super.destinationFolder,
  });
}
