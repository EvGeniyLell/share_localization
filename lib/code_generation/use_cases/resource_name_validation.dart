import 'package:share_localization/code_generation/exceptions/duplicate_resource_name_exception.dart';
import 'package:share_localization/code_generation/exceptions/invalid_resource_name_exception.dart';
import 'package:share_localization/common/common.dart';

/// A valid resource name: an identifier with no `-` or `.`. This identifier
/// rule is shared by all platforms.
final _validResourceName = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

/// One key of a bundle with its final resource name.
class ResourceNameEntry {
  /// The key as written in the source bundle.
  final String key;

  /// The final resource name, including any file prefix.
  final String name;

  /// The name without any file prefix. For platforms without a prefix, pass
  /// the same value as [name].
  final String baseName;

  final String? _identity;

  const ResourceNameEntry({
    required this.key,
    required this.name,
    required this.baseName,
    String? identity,
  }) : _identity = identity;

  /// The value compared to find duplicates. Two entries clash when their
  /// identities are equal. Defaults to [name]. [name] is still the value
  /// checked by the identifier rule and the empty base check.
  String get identity => _identity ?? name;
}

/// Throws before any file is written if a key gives an invalid resource
/// name, or if two entries have the same [ResourceNameEntry.identity] (a
/// duplicate). Names are checked against the identifier rule, identities
/// only for duplicates. One error is thrown as is, several as a
/// [CompositeException] in key order.
void validateResourceNames({
  required ResourcePlatform platform,
  required String bundleName,
  required Iterable<ResourceNameEntry> entries,
}) {
  final errors = <AppException>[];
  // The first key that took each identity, for duplicate reports.
  final keyByIdentity = <String, String>{};
  for (final entry in entries) {
    final name = entry.name;
    if (!_validResourceName.hasMatch(name)) {
      errors.add(
        InvalidResourceNameException(
          platform: platform,
          key: entry.key,
          name: name,
          bundleName: bundleName,
        ),
      );
      continue;
    }
    // Only reachable with a file prefix: without one, an empty base is
    // already an empty name and was reported above.
    if (entry.baseName.isEmpty) {
      errors.add(
        InvalidResourceNameException(
          platform: platform,
          key: entry.key,
          name: name,
          bundleName: bundleName,
          reason: InvalidResourceNameReason.emptyKeyBase,
        ),
      );
      continue;
    }
    final firstKey = keyByIdentity[entry.identity];
    if (firstKey != null) {
      errors.add(
        DuplicateResourceNameException(
          platform: platform,
          key: entry.key,
          otherKey: firstKey,
          name: name,
          bundleName: bundleName,
        ),
      );
      continue;
    }
    keyByIdentity[entry.identity] = entry.key;
  }
  if (errors.isEmpty) {
    return;
  }
  if (errors.length == 1) {
    throw errors.single;
  }
  throw CompositeException(errors);
}
