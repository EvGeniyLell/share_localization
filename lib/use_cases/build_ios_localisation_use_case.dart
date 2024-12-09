import 'package:meta/meta.dart';
import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/utils/common.dart';
import 'package:share_localisation/utils/string_case_transform_extension.dart';

part 'build_ios_localisation_use_case_cxstrings.dart';
part 'build_ios_localisation_use_case_swift.dart';

class BuildIosLocalisationUseCase {
  const BuildIosLocalisationUseCase();

  AppTask<void> call(SettingsDto settings, LocalisationDto localisation) {
    return runAppTaskSafely(() async {
      // final localisationExceptions = checkLocalisation(settings, localisation);
      // if (localisationExceptions.isNotEmpty) {
      //   throw CompositeException(localisationExceptions);
      // }
      // final keyExceptions = checkKeys(settings, localisation);
      // if (keyExceptions.isNotEmpty) {
      //   throw CompositeException(keyExceptions);
      // }
    });
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
  String iosCXStringKey() {
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
