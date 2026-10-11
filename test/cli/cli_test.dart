import 'dart:io';

import 'package:share_localization/common/common.dart';
import 'package:test/test.dart';

/// Runs the real executable. Tests run from the package root.
Future<ProcessResult> runCli(List<String> arguments) {
  return Process.run(Platform.resolvedExecutable, [
    'bin/share_localization.dart',
    ...arguments,
  ]);
}

int countOf(String text, String pattern) => pattern.allMatches(text).length;

void main() {
  group('CLI', () {
    test('--help prints usage to stdout and exits 0', () async {
      final result = await runCli(['--help']);

      expect(result.exitCode, 0);
      expect(result.stdout, contains('Usage: share_localization'));
      expect(result.stderr, isEmpty);
    });

    test('-h behaves like --help', () async {
      final result = await runCli(['-h']);

      expect(result.exitCode, 0);
      expect(result.stdout, contains('Usage: share_localization'));
    });

    test('--version prints the version and exits 0', () async {
      final result = await runCli(['--version']);

      expect(result.exitCode, 0);
      expect(result.stdout, contains(appVersion));
      expect(result.stderr, isEmpty);
    });

    test('unknown option goes to stderr and exits 1', () async {
      final result = await runCli(['--nope']);

      expect(result.exitCode, 1);
      expect(result.stderr, contains('Unknown option: --nope'));
      expect(result.stdout, isNot(contains('Unknown option')));
    });

    test('--settings without a value goes to stderr and exits 1', () async {
      final result = await runCli(['--settings']);

      expect(result.exitCode, 1);
      expect(result.stderr, contains('--settings requires a path'));
    });

    test('missing settings file exits 1 and reports the error once', () async {
      final result = await runCli(['--settings', 'missing.json']);

      expect(result.exitCode, 1);
      expect(countOf(result.stderr as String, 'SettingsNotFoundException'), 1);
      expect(result.stdout, isNot(contains('SettingsNotFoundException')));
    });

    test('--verbose adds a stack trace to stderr', () async {
      final result = await runCli(['--verbose', '--settings', 'missing.json']);

      expect(result.exitCode, 1);
      expect(result.stderr, contains('Stack trace:'));
    });
  });
}
