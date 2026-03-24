import 'package:meta/meta.dart';

abstract class PlatformOptionsDto {
  final String destinationFolder;

  const PlatformOptionsDto({required this.destinationFolder});
}

@immutable
class IosOptionsDto extends PlatformOptionsDto {
  final String? bundleName;
  final String? classAccessLevel;

  const IosOptionsDto({
    required this.bundleName,
    required this.classAccessLevel,
    required super.destinationFolder,
  });
}

@immutable
class FlutterOptionsDto extends PlatformOptionsDto {
  const FlutterOptionsDto({required super.destinationFolder});
}

@immutable
class AndroidOptionsDto extends PlatformOptionsDto {
  final bool useCamelCase;
  final bool useFilePrefixForKeys;

  const AndroidOptionsDto({
    required bool? useCamelCase,
    required bool? useFilePrefixForKeys,
    required super.destinationFolder,
  }) : useCamelCase = useCamelCase ?? false,
       useFilePrefixForKeys = useFilePrefixForKeys ?? false;
}
