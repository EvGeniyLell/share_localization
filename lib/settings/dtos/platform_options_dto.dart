import 'package:meta/meta.dart';

abstract class PlatformOptionsDto {
  final String destinationFolder;

  const PlatformOptionsDto({
    required this.destinationFolder,
  });
}

@immutable
class IosOptionsDto extends PlatformOptionsDto {
  final String? bundleName;

  const IosOptionsDto({
    required this.bundleName,
    required super.destinationFolder,
  });
}

@immutable
class FlutterOptionsDto extends PlatformOptionsDto {
  const FlutterOptionsDto({
    required super.destinationFolder,
  });
}

@immutable
class AndroidOptionsDto extends PlatformOptionsDto {
  final bool useCamelCase;

  const AndroidOptionsDto({
    required bool? useCamelCase,
    required super.destinationFolder,
  }) : useCamelCase = useCamelCase ?? true;
}
