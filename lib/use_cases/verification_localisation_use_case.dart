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
    });
  }

  @visibleForTesting
  List<VerificationLocalisationException> checkLocalisation(
    SettingsDto settings,
    LocalisationDto localisation,
  ) {
    return settings.languages
        .mapWhereEvery(
          localisation.languages,
          test: (s, l) => s.key != l.key,
          toElement: (s) => VerificationLocalisationException(
            VerificationLocalisationExceptionType.missingLanguage,
            'Language ${s.key} not found in ${localisation.name}',
            key: s.key,
          ),
        )
        .toList();
  }

  @visibleForTesting
  List<VerificationLocalisationException> checkKeys(
    SettingsDto settings,
    LocalisationDto localisation,
  ) {
    localisation.keys.map((key) {
      key.arguments.map((argument) {
        // argument
        // .
        // final hasArgument = settings.arguments.any((s) {
        // return argument.name == s.name;
        // });
        // return hasArgument
        // ? null
        //     : VerificationLocalisationException(
        // VerificationLocalisationExceptionType.missingArgument,
        // 'Argument ${argument.name} not found in ${localisation.name}',
        // );
      });
    });

    return [];
  }

  @visibleForTesting
  List<VerificationLocalisationException> checkKeyArguments(
    SettingsDto settings,
    LocalisationKeyDto key,
  ) {
    final argumentNames = key.arguments.map((argument) => argument.name);
    final exceptions = key.localizations.map((localization) {
      final messageArguments = localization.message.getMessageArguments();
      final intersectionMap = argumentNames.intersection(
        messageArguments,
        test: (argName, messageArgName) => argName == messageArgName,
      );

      return [
        ...intersectionMap.$1.map((argName) {
          return VerificationLocalisationException(
            VerificationLocalisationExceptionType.missingArgument,
            'Argument $argName not found in ${key.key}'
            ' for ${localization.languageKey} language',
            key: '${localization.languageKey}:$argName',
          );
        }),
        ...intersectionMap.$3.map((argName) {
          return VerificationLocalisationException(
            VerificationLocalisationExceptionType.missingArgument,
            '1) Argument $argName not found in ${key.key}',
            key: argName,
          );
        }),
      ];
    });
    return exceptions.expand((e) => e).toList();
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
extension ListMergeExtension<E> on Iterable<E> {
  /// Return tuple of intersection of two iterables,
  /// - `$1`: for items presents only in `left` list,
  /// - `$2`: for common,
  /// - `$3`: for items presents only in `right` list.
  (Iterable<E> left, Iterable<E> common, Iterable<E> righ) intersection(
    Iterable<E> other, {
    required bool Function(E l, E r) test,
  }) {
    final common = {
      ...this,
      ...other,
    };
    final onlyLeft = mapWhereEvery<E>(
      other,
      test: (l, r) => !test(l, r),
      toElement: (e) {
        common.remove(e);
        return e;
      },
    );
    final onlyRight = other.mapWhereEvery<E>(
      this,
      test: (l, r) => !test(l, r),
      toElement: (e) {
        common.remove(e);
        return e;
      },
    );
    return (onlyLeft, common, onlyRight);
  }

  /// Return a new iterable with `every elements` that satisfy the [test]
  /// and mapped to [R] type.
  Iterable<R> mapWhereEvery<R>(
    Iterable<E> other, {
    required bool Function(E l, E r) test,
    required R Function(E e) toElement,
  }) {
    return map((lItem) {
      final has = other.every((rItem) => test(lItem, rItem));
      return has ? toElement(lItem) : null;
    }).whereType<R>();
  }

  /// Return a new iterable with `any elements` that satisfy the [test]
  /// and mapped to [R] type.
  Iterable<R> mapWhereAny<R>(
    Iterable<E> other, {
    required bool Function(E l, E r) test,
    required R Function(E e) toElement,
  }) {
    return map((lItem) {
      final has = other.any((rItem) => test(lItem, rItem));
      return has ? toElement(lItem) : null;
    }).whereType<R>();
  }
}
