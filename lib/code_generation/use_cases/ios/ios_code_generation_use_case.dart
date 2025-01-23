import 'package:meta/meta.dart';
import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/use_cases/code_generation_use_case.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';
import 'package:share_localization/settings/settings.dart' as settings;

part 'ios_code_generation_use_case_swift.dart';
part 'ios_code_generation_use_case_xcstrings.dart';

class IosCodeGenerationUseCase extends CodeGenerationUseCase {
  static const xcStringExtension = 'xcstrings';
  static const swiftExtension = 'swift';

  const IosCodeGenerationUseCase(super.fileService);

  @override
  Task<void> call(settings.SettingsDto settings, LocalizationDto localization) {
    return runAppTaskSafely(() async {
      final ios = settings.ios;
      if (ios == null) {
        throw const BuildLocalizationException.missingIosSettings();
      }
      final xcStrings = generateXCStrings(settings, localization);
      await fileService.createFile(
        path: filePath(ios, localization, xcStringExtension),
        content: xcStrings,
      );
      final swift = generateSwift(settings, localization);
      await fileService.createFile(
        path: filePath(ios, localization, swiftExtension),
        content: swift,
      );
    });
  }

  String filePath(
    settings.IosOptionsDto settings,
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
