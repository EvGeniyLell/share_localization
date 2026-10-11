import 'package:meta/meta.dart';
import 'package:share_localization/code_generation/exceptions/duplicate_resource_name_exception.dart';
import 'package:share_localization/common/exceptions/app_exception.dart';

/// Why a resource name is rejected.
enum InvalidResourceNameReason {
  /// The name is not a valid XML identifier.
  invalidName,

  /// The key has no name part of its own, so only the file prefix is left.
  emptyKeyBase,
}

/// The final resource name of a platform is not a valid identifier.
///
/// Thrown when the name is empty or starts with a digit, which happens when
/// the key has no ASCII letters or the file prefix is a digit-leading name.
/// Also thrown when the key has no name part of its own and only the file
/// prefix would remain.
@immutable
class InvalidResourceNameException implements AppException {
  final ResourcePlatform platform;
  final String key;
  final String name;
  final String bundleName;
  final InvalidResourceNameReason reason;

  const InvalidResourceNameException({
    required this.platform,
    required this.key,
    required this.name,
    required this.bundleName,
    this.reason = InvalidResourceNameReason.invalidName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvalidResourceNameException &&
          runtimeType == other.runtimeType &&
          platform == other.platform &&
          key == other.key &&
          name == other.name &&
          bundleName == other.bundleName &&
          reason == other.reason;

  @override
  int get hashCode => Object.hash(platform, key, name, bundleName, reason);

  @override
  String toString() {
    return switch (reason) {
      InvalidResourceNameReason.invalidName =>
        '$InvalidResourceNameException: key "$key" in "$bundleName" '
            'becomes ${platform.label} name "$name"\n'
            'Use only ASCII letters, digits and underscore, and do not start '
            'with a digit or leave the name empty.',
      InvalidResourceNameReason.emptyKeyBase =>
        '$InvalidResourceNameException: key "$key" in "$bundleName" '
            'has no name part of its own, so its ${platform.label} name would '
            'be only the file prefix "$name"\n'
            'Use at least one ASCII letter or digit in the key.',
    };
  }
}
