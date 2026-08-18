import 'dart:io';

import 'package:share_localization/common/common.dart';
import 'package:test/test.dart';

void main() {
  test('appVersion matches pubspec.yaml', () async {
    final pubspec = await File('pubspec.yaml').readAsString();
    final match = RegExp(
      r'^version:\s*(.+)$',
      multiLine: true,
    ).firstMatch(pubspec);
    final pubspecVersion = match?.group(1)?.trim();
    expect(
      appVersion,
      equals(pubspecVersion),
      reason: 'Update appVersion in lib/common/utils/consts.dart '
          'to match the version in pubspec.yaml.',
    );
  });
}
