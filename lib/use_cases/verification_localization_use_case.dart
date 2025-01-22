import 'package:meta/meta.dart';
import 'package:share_localization/dtos/dtos.dart';
import 'package:share_localization/exceptions/exceptions.dart';
import 'package:share_localization/utils/common.dart';

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

    final exceptions = key.translation.map((localization) {
      final messageArguments = localization.message.getMessageArguments();
      final (extraArgs, commonArgs, missingArgs) =
          argumentNames.intersection(messageArguments);

      return [
        ...extraArgs.map((argName) {
          return VerificationLocalizationException.extraArgument(
            argument: argName,
            key: key.key,
            language: localization.languageKey,
            sourceName: localization.name,
          );
        }),
        ...missingArgs.map((argName) {
          return VerificationLocalizationException.missingArgument(
            argument: argName,
            key: key.key,
            language: localization.languageKey,
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

@visibleForTesting
extension ListMergeExtension<E> on List<E> {
  /// Return tuple of intersection of two lists,
  /// - `$1`: for items presents only in `left` list,
  /// - `$2`: for common,
  /// - `$3`: for items presents only in `right` list.
  (List<E> left, List<E> common, List<E> righ) intersection(
    List<E> other, {
    bool Function(E l, E r)? test,
  }) {
    final resolvedTest = test ?? (l, r) => l == r;
    final common = {
      ...this,
      ...other,
    };
    final onlyLeft = mapWhereEvery(
      other,
      test: (l, r) => !resolvedTest(l, r),
      toElement: (e) {
        common.remove(e);
        return e;
      },
    );
    final onlyRight = other.mapWhereEvery(
      this,
      test: (l, r) => !resolvedTest(l, r),
      toElement: (e) {
        common.remove(e);
        return e;
      },
    );
    return (onlyLeft.toList(), common.toList(), onlyRight.toList());
  }

  /// Return a new list with `every elements` that satisfy the [test]
  /// and mapped to [R] type.
  List<R> mapWhereEvery<R, EE>(
    List<EE> other, {
    required bool Function(E l, EE r) test,
    required R Function(E e) toElement,
  }) {
    return map((lItem) {
      final has = other.every((rItem) => test(lItem, rItem));
      return has ? toElement(lItem) : null;
    }).whereType<R>().toList();
  }

  /// Return a new list with `any elements` that satisfy the [test]
  /// and mapped to [R] type.
  List<R> mapWhereAny<R, EE>(
    List<EE> other, {
    required bool Function(E l, EE r) test,
    required R Function(E e) toElement,
  }) {
    return map((lItem) {
      final has = other.any((rItem) => test(lItem, rItem));
      return has ? toElement(lItem) : null;
    }).whereType<R>().toList();
  }
}
