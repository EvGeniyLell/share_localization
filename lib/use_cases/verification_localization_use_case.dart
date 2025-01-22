import 'package:meta/meta.dart';
import 'package:share_localization/dtos/dtos.dart';
import 'package:share_localization/exceptions/exceptions.dart';
import 'package:share_localization/utils/common.dart';
import 'package:share_localization/utils/list_merge_extension.dart';

class VerificationLocalizationUseCase {
  final List<Type> skipErrorTypes;

  const VerificationLocalizationUseCase({this.skipErrorTypes = const []});

  AppTask<void> call(SettingsDto settings, LocalizationDto localization) {
    return runAppTaskSafely(() async {
      final localizationExceptions = checkLocalization(settings, localization);
      if (localizationExceptions.isNotEmpty) {
        throw CompositeException(localizationExceptions);
      }
      final keyExceptions = checkKeys(settings, localization);
      if (keyExceptions.isNotEmpty) {
        throw CompositeException(keyExceptions);
      }
    });
  }

  @visibleForTesting
  List<VerificationLocalizationException> checkLocalization(
    SettingsDto settings,
    LocalizationDto localization,
  ) {
    return settings.languages.mapWhereEvery(
      localization.languages,
      test: (settingsLanguage, localizationLanguage) {
        return settingsLanguage.key != localizationLanguage.key;
      },
      toElement: (settingsLanguage) {
        return VerificationLocalizationException.missingLanguage(
          language: settingsLanguage.key,
          sourceName: localization.name,
        );
      },
    ).toList();
  }

  @visibleForTesting
  List<VerificationLocalizationException> checkKeys(
    SettingsDto settings,
    LocalizationDto localization,
  ) {
    final exceptions = localization.keys.map((key) {
      return [
        ...checkKeyArguments(settings, localization, key),
        ...checkKeyTranslations(settings, localization, key),
      ];
    });

    return exceptions.expand((e) => e).toList();
  }

  @visibleForTesting
  List<VerificationLocalizationException> checkKeyArguments(
    SettingsDto settings,
    LocalizationDto localization,
    LocalizationKeyDto key,
  ) {
    final argumentNames = key.arguments.map((argument) {
      return argument.name;
    }).toList();

    final exceptions = key.translation.map((keyTranslation) {
      final messageArguments = keyTranslation.message.getMessageArguments();
      final (extraArgs, commonArgs, missingArgs) =
          argumentNames.intersection(messageArguments);

      return [
        ...extraArgs.map((argName) {
          return VerificationLocalizationException.extraArgument(
            argument: argName,
            key: key.key,
            language: keyTranslation.languageKey,
            sourceName: localization.name,
          );
        }),
        ...missingArgs.map((argName) {
          return VerificationLocalizationException.missingArgument(
            argument: argName,
            key: key.key,
            language: keyTranslation.languageKey,
            sourceName: localization.name,
          );
        }),
      ];
    });
    return exceptions.expand((e) => e).toList();
  }

  @visibleForTesting
  List<VerificationLocalizationException> checkKeyTranslations(
    SettingsDto settings,
    LocalizationDto localization,
    LocalizationKeyDto key,
  ) {
    return settings.languages.mapWhereEvery(
      key.translation,
      test: (settingsLanguage, translation) {
        return settingsLanguage.key != translation.languageKey;
      },
      toElement: (settingsLanguage) {
        return VerificationLocalizationException.missingTranslation(
          key: key.key,
          language: settingsLanguage.key,
          sourceName: localization.name,
        );
      },
    ).toList();
  }
}

@visibleForTesting
extension MessageArgumentsExtension on String {
  List<String> getMessageArguments() {
    final regExp = RegExp('{(.*?)}');
    final matches = regExp.allMatches(this);
    return matches.map((match) => match.group(1)).whereType<String>().toList();
  }
}


