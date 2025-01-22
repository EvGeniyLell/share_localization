import 'package:meta/meta.dart';
import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/exceptions/exceptions.dart';
import 'package:share_localisation/use_cases/build_localisation_use_case.dart';
import 'package:share_localisation/utils/common.dart';
import 'package:share_localisation/utils/string_case_transform_extension.dart';

part 'build_ios_localisation_use_case_swift.dart';
part 'build_ios_localisation_use_case_xcstrings.dart';

class BuildIosLocalisationUseCase extends BuildLocalisationUseCase {
  static const xcStringExtension = 'xcstrings';
  static const swiftExtension = 'swift';

  const BuildIosLocalisationUseCase();

  @override
  AppTask<void> call(SettingsDto settings, LocalisationDto localisation) {
    return runAppTaskSafely(() async {
      final ios = settings.ios;
      if (ios == null) {
        throw const BuildLocalisationException.missingIosSettings();
      }
      final xcStrings = buildXCStrings(settings, localisation);
      await createFile(
        filePath(ios, localisation, xcStringExtension),
        xcStrings,
      );
      final swift = buildSwift(settings, localisation);
      await createFile(
        filePath(ios, localisation, swiftExtension),
        swift,
      );
    });
  }

  String filePath(
    IosSettingsDto settings,
    LocalisationDto localisation,
    String extension,
  ) {
    return '${settings.destinationFolder}'
        '/${localisation.name.baseFilename().camelCase().capitalize()}'
        '.$extension';
  }
}

@visibleForTesting
extension LocalisationKeyDtoTypeToFlutter on LocalisationKeyDtoType {
  String get iosMarker => switch (this) {
        LocalisationKeyDtoType.string => '@',
        LocalisationKeyDtoType.int => 'lld',
        LocalisationKeyDtoType.double => 'lf',
      };

  String get iosType => switch (this) {
        LocalisationKeyDtoType.string => 'String',
        LocalisationKeyDtoType.int => 'Int',
        LocalisationKeyDtoType.double => 'Double',
      };
}

@visibleForTesting
extension IosLocalisationKeyDto on LocalisationKeyDto {
  /// return string aka "loginMessage%@%lld%@"
  String iosXCStringKey() {
    final arg = arguments.map((argument) {
      return '%${argument.type.iosMarker}';
    });
    return [key, ...arg].join();
  }

  /// return string aka "loginMessage\(name)\(pass)"
  String iosSwiftKey() {
    final arg = arguments.map((argument) {
      return '\\(${argument.name})';
    });
    return [key, ...arg].join();
  }
}

@visibleForTesting
extension IosLocalisationKeyTranslationDto on LocalisationKeyTranslationDto {
  /// return string aka "Hi %1$@! Number %2$lld from %3$@?"
  String iosMessage(List<LocalisationKeyArgumentDto> arguments) {
    String result = message;
    for (int i = 0; i < arguments.length; i++) {
      final argument = arguments[i];
      result = result.replaceAll(
          '{${argument.name}}',
          '%${i + 1}\$'
              '${argument.type.iosMarker}');
    }
    return result;
  }
}
