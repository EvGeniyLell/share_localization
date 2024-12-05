import 'package:meta/meta.dart';
import 'package:share_localisation/dtos/dtos.dart';
import 'package:share_localisation/exceptions/exceptions.dart';
import 'package:share_localisation/utils/common.dart';

class VerificationLocalisationUseCase {
  // void addError(VerificationLocalisationException error) {
  //   errors.add(error);
  // }

  AppTask<void> call(SettingsDto settings, LocalisationDto localisation) {
    return runAppTaskSafely(() async {
      final localisationExceptions = checkLocalisation(settings, localisation);
      if (localisationExceptions.isNotEmpty) {
        throw CompositeException(localisationExceptions);
      }
      final keyExceptions = checkKeys(settings, localisation);
      if (keyExceptions.isNotEmpty) {
        throw CompositeException(keyExceptions);
      }
    });
  }

  @visibleForTesting
  List<VerificationLocalisationException> checkLocalisation(
    SettingsDto settings,
    LocalisationDto localisation,
  ) {
    return settings.languages.mapWhereEvery(
      localisation.languages,
      test: (settingsLanguage, localisationLanguage) {
        return settingsLanguage.key != localisationLanguage.key;
      },
      toElement: (settingsLanguage) {
        return VerificationLocalisationException.missingLanguage(
          language: settingsLanguage.key,
          sourceName: localisation.name,
        );
      },
    ).toList();
  }

  @visibleForTesting
  List<VerificationLocalisationException> checkKeys(
    SettingsDto settings,
    LocalisationDto localisation,
  ) {
    final exceptions = localisation.keys.map((key) {
      return [
        ...checkKeyArguments(settings, key),
        ...checkKeyTranslations(settings, key),
      ];
    });

    return exceptions.expand((e) => e).toList();
  }

  @visibleForTesting
  List<VerificationLocalisationException> checkKeyArguments(
    SettingsDto settings,
    LocalisationKeyDto key,
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
          return VerificationLocalisationException.extraArgument(
            argument: argName,
            key: key.key,
            language: localization.languageKey,
          );
        }),
        ...missingArgs.map((argName) {
          return VerificationLocalisationException.missingArgument(
            argument: argName,
            key: key.key,
            language: localization.languageKey,
          );
        }),
      ];
    });
    return exceptions.expand((e) => e).toList();
  }

  @visibleForTesting
  List<VerificationLocalisationException> checkKeyTranslations(
    SettingsDto settings,
    LocalisationKeyDto key,
  ) {
    return settings.languages.mapWhereEvery(
      key.translation,
      test: (settingsLanguage, translation) {
        return settingsLanguage.key != translation.languageKey;
      },
      toElement: (settingsLanguage) {
        return VerificationLocalisationException.missingTranslation(
          language: settingsLanguage.key,
          key: key.key,
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
