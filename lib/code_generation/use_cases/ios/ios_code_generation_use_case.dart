import 'package:meta/meta.dart';
import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/exceptions/duplicate_resource_name_exception.dart';
import 'package:share_localization/code_generation/use_cases/code_generation_use_case.dart';
import 'package:share_localization/code_generation/use_cases/resource_name_validation.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';
import 'package:share_localization/settings/settings.dart';

part 'ios_code_generation_use_case_swift.dart';
part 'ios_code_generation_use_case_xcstrings.dart';

class IosCodeGenerationUseCase extends CodeGenerationUseCase {
  static const xcStringExtension = 'xcstrings';
  static const swiftExtension = 'swift';

  const IosCodeGenerationUseCase(super.fileService);

  @override
  Task<void> call(SettingsDto settings, LocalizationDto localization) {
    return runAppTaskSafely(() async {
      final IosSettingsDto? pSettings = settings.toPlatformSettingsDto();
      if (pSettings == null) {
        throw const BuildLocalizationException.missingIosSettings();
      }
      _validateResourceNames(localization);
      final xcStrings = generateXCStrings(pSettings, localization);
      await fileService.createFile(
        path: filePath(pSettings, localization, xcStringExtension),
        content: xcStrings,
      );
      final swift = generateSwift(pSettings, localization);
      await fileService.createFile(
        path: filePath(pSettings, localization, swiftExtension),
        content: swift,
      );
    });
  }

  /// Throws before any file is written if a key gives an invalid or duplicate
  /// name, see [validateResourceNames].
  ///
  /// Swift allows one static member per name and argument types, so two keys
  /// clash only when they have the same camelCase base and the same ordered
  /// argument types. That is their xcstrings key, used as the identity. The
  /// argument names do not matter: `foo(_ name: String)` and
  /// `foo(_ user: String)` are the same declaration.
  void _validateResourceNames(LocalizationDto localization) {
    validateResourceNames(
      platform: ResourcePlatform.ios,
      bundleName: localization.name,
      entries: localization.keys.map((key) {
        final name = _iosItemName(key);
        return ResourceNameEntry(
          key: key.key,
          name: name,
          baseName: name,
          identity: key.iosXCStringKey(),
        );
      }),
    );
  }

  String filePath(
    IosSettingsDto settings,
    LocalizationDto localization,
    String extension,
  ) {
    return '${settings.options.destinationFolder}'
        '/${localization.name.baseFilename().camelCase().capitalize()}'
        '${localizationPostfix.capitalize()}.$extension';
  }
}

/// The Swift identifier of [key], used as the static member name in the Swift
/// file and as the base of its xcstrings keys, and checked by
/// [validateResourceNames].
String _iosItemName(LocalizationKeyDto key) => key.key.camelCase();

@visibleForTesting
extension LocalizationKeyDtoTypeToIos on LocalizationKeyDtoType {
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
    return [_iosItemName(this), ...arg].join();
  }

  /// return string aka "loginMessage\(name)\(pass)"
  String iosSwiftKey() {
    final arg = arguments.map((argument) {
      return '\\(${argument.name.camelCase()})';
    });
    return [_iosItemName(this), ...arg].join();
  }
}

@visibleForTesting
extension IosLocalizationKeyTranslationDto on LocalizationKeyTranslationDto {
  /// return string aka "Hi %1$@! Number %2$lld from %3$@?"
  ///
  /// With arguments the message is a format string, so a literal `%` is
  /// escaped as `%%` before placeholders are replaced.
  String iosMessage(List<LocalizationKeyArgumentDto> arguments) {
    String result = arguments.isEmpty ? message : message.replaceAll('%', '%%');
    for (int i = 0; i < arguments.length; i++) {
      final argument = arguments[i];
      result = result.replaceAll(
        '{${argument.name}}',
        '%${i + 1}\$'
            '${argument.type.iosMarker}',
      );
    }
    return result;
  }
}

extension StringToIos on String {
  /// Escapes text for use inside a JSON string value in `.xcstrings`.
  ///
  /// The backslash must be escaped first, otherwise the backslashes added by
  /// the later steps would be doubled. Other control characters U+0000..U+001F
  /// are written as `\u00XX`, since raw ones make the JSON invalid.
  String iosXCSTranslationEscape() {
    return replaceAll(RegExp(r'\\'), r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n')
        .replaceAll('\t', r'\t')
        .replaceAll('\r', r'\r')
        .replaceAllMapped(
          RegExp(r'[\x00-\x1F]'),
          (match) =>
              '\\u${match[0]!.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}',
        );
  }

  /// Escapes text for use inside a Swift `///` doc comment.
  ///
  /// A real newline or carriage return ends the `///` line in Swift, so both
  /// are written as the two-character sequences `\n` and `\r`.
  String iosSwiftTranslationEscape() {
    return replaceAll(
      '"',
      r'\"',
    ).replaceAll('\n', r'\n').replaceAll('\r', r'\r');
  }
}
