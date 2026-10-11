import 'package:meta/meta.dart';
import 'package:share_localization/common/exceptions/app_exception.dart';

/// The platform whose resource names collided.
enum ResourcePlatform {
  android('Android'),
  ios('iOS'),
  flutter('Flutter');

  const ResourcePlatform(this.label);

  /// Human readable platform name used in messages.
  final String label;
}

/// Two keys of one bundle give the same final resource name on a platform.
///
/// Resource names are compared exactly, so the same name would be defined
/// twice in one file. [otherKey] is the first key that took the name,
/// [key] is the later key that repeats it.
@immutable
class DuplicateResourceNameException implements AppException {
  final ResourcePlatform platform;
  final String key;
  final String otherKey;
  final String name;
  final String bundleName;

  /// The bundle of [otherKey] when it is another bundle, or null when both
  /// keys are in [bundleName].
  final String? otherBundleName;

  const DuplicateResourceNameException({
    required this.platform,
    required this.key,
    required this.otherKey,
    required this.name,
    required this.bundleName,
    this.otherBundleName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuplicateResourceNameException &&
          runtimeType == other.runtimeType &&
          platform == other.platform &&
          key == other.key &&
          otherKey == other.otherKey &&
          name == other.name &&
          bundleName == other.bundleName &&
          otherBundleName == other.otherBundleName;

  @override
  int get hashCode =>
      Object.hash(platform, key, otherKey, name, bundleName, otherBundleName);

  @override
  String toString() {
    final other = otherBundleName;
    if (other != null) {
      return '$DuplicateResourceNameException: key "$otherKey" in "$other" '
          'and key "$key" in "$bundleName" both become ${platform.label} '
          'name "$name"\n'
          'Rename one of the keys so that each key gives a unique name.';
    }
    return '$DuplicateResourceNameException: keys "$otherKey" and '
        '"$key" in "$bundleName" both become ${platform.label} name "$name"\n'
        'Rename one of the keys so that each key gives a unique name.';
  }
}
