import 'package:meta/meta.dart';
import 'package:share_localization/exceptions/exceptions.dart';
import 'package:share_localization/use_cases/build_localization_use_case.dart';
import 'package:share_localization/utils/string_case_transform_extension.dart';

part 'build_ios_localization_use_case_swift.dart';
part 'build_ios_localization_use_case_xcstrings.dart';

class BuildIosLocalizationUseCase extends BuildLocalizationUseCase {
  static const xcStringExtension = 'xcstrings';
  static const swiftExtension = 'swift';

  const BuildIosLocalizationUseCase();

  @override
  AppTask<void> call(SettingsDto settings, LocalizationDto localization) {
    return runAppTaskSafely(() async {
      final ios = settings.ios;
      if (ios == null) {
        throw const BuildLocalizationException.missingIosSettings();
      }
      final xcStrings = buildXCStrings(settings, localization);
      await createFile(
        filePath(ios, localization, xcStringExtension),
        xcStrings,
      );
      final swift = buildSwift(settings, localization);
      await createFile(
        filePath(ios, localization, swiftExtension),
        swift,
      );
    });
  }

  String filePath(
    IosSettingsDto settings,
    LocalizationDto localization,
    String extension,
  ) {
    return '${settings.destinationFolder}'
        '/${localization.name.baseFilename().camelCase().capitalize()}'
        '.$extension';
  }
}

@visibleForTesting
extension LocalizationKeyDtoTypeToFlutter on LocalizationKeyDtoType {
  String get iosMarker => switch (this) {
        LocalizationKeyDtoType.string => '@',
        LocalizationKeyDtoType.int => 'lld',
        LocalizationKeyDtoType.double => 'lf',
      };

  String get iosType => switch (this) {
        LocalizationKeyDtoType.string => 'String',
        LocalizationKeyDtoType.int => 'Int',
        LocalizationKeyDtoType.double => 'Double',
      };
}

@visibleForTesting
extension IosLocalizationKeyDto on LocalizationKeyDto {
  /// return string aka "loginMessage%@%lld%@"
  String iosXCStringKey() {
    final arg = arguments.map((argument) {
      return '%${argument.type.iosMarker}';
    });
    return [key.camelCase(), ...arg].join();
  }

  /// return string aka "loginMessage\(name)\(pass)"
  String iosSwiftKey() {
    final arg = arguments.map((argument) {
      return '\\(${argument.name.camelCase()})';
    });
    return [key.camelCase(), ...arg].join();
  }
}

@visibleForTesting
extension IosLocalizationKeyTranslationDto on LocalizationKeyTranslationDto {
  /// return string aka "Hi %1$@! Number %2$lld from %3$@?"
  String iosMessage(List<LocalizationKeyArgumentDto> arguments) {
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
