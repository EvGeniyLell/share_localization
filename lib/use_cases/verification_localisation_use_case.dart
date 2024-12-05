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
          test: (s, l) => s.abbreviation != l.abbreviation,
          toElement: (s) => VerificationLocalisationException(
            VerificationLocalisationExceptionType.missingLanguage,
            'Language ${s.abbreviation} not found in ${localisation.name}',
            key: s.abbreviation,
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
        ...?intersectionMap[-1]?.map((argName) {
          return VerificationLocalisationException(
            VerificationLocalisationExceptionType.missingArgument,
            'Argument $argName not found in ${key.key}'
                ' for ${localization.key} language',
            key: '${localization.key}:$argName',
          );
        }),
        ...?intersectionMap[1]?.map((argName) {
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
  /// Return map of intersection of two iterables,
  /// where keys for values are:
  /// - `-1`: is excluded from the right list,
  /// - `0`: is common,
  /// - `1`: is excluded from the left list.
  Map<int, Iterable<E>> intersection(
    Iterable<E> other, {
    required bool Function(E l, E r) test,
  }) {
    final common = {
      ...this,
      ...other,
    };
    print('>>> R: $this');
    print('>>> L: $other');
    final rExcluded = mapWhereEvery<E>(
      other,
      test: (l, r) {
        print('R: test? $l $r = ${test(l, r)}');
        return !test(l, r);
      },
      toElement: (e) {
        print('R: remove $e');
        common.remove(e);
        return e;
      },
    );
    print('RRR: excluded: $rExcluded');

    final lExcluded = other.mapWhereEvery<E>(
      this,
      test: (l, r) {
        print('L: test? $l $r = ${test(l, r)}');
        return !test(l, r);
      },
      toElement: (e) {
        print('L: remove $e');
        common.remove(e);
        return e;
      },
    );
    print('LLL: excluded: $lExcluded');
    return <int, Iterable<E>>{
      -1: rExcluded,
      0: common,
      1: lExcluded,
    };
  }

  /// Return a new iterable with elements that satisfy the [test]
  /// mapped to [R] type.
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
