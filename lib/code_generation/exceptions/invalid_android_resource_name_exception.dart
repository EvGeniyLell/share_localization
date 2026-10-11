import 'package:meta/meta.dart';
import 'package:share_localization/common/exceptions/app_exception.dart';

/// The final Android resource name is not a valid XML identifier.
///
/// Thrown when the name is empty or starts with a digit, which happens when
/// the key has no ASCII letters or the file prefix is a digit-leading name.
@immutable
class InvalidAndroidResourceNameException implements AppException {
  final String key;
  final String name;
  final String bundleName;

  const InvalidAndroidResourceNameException({
    required this.key,
    required this.name,
    required this.bundleName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvalidAndroidResourceNameException &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          name == other.name &&
          bundleName == other.bundleName;

  @override
  int get hashCode => Object.hash(key, name, bundleName);

  @override
  String toString() {
    return '$InvalidAndroidResourceNameException: key "$key" in "$bundleName" '
        'becomes Android name "$name"\n'
        'Use only ASCII letters, digits and underscore, and do not start '
        'with a digit or leave the name empty.';
  }
}
