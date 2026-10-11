import 'dart:io';

import 'package:share_localization/common/common.dart';
import 'package:test/test.dart';

R _unusedBuildDto<R extends Object>(JsonData data) =>
    throw UnimplementedError();

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('json_data_test_');
  });

  tearDown(() async {
    // Restore permissions so the temp directory can be deleted.
    await Process.run('chmod', ['644', '${tempDir.path}/unreadable.json']);
    await tempDir.delete(recursive: true);
  });

  group('JsonData.fromFile', () {
    test('missing file throws SettingsNotFoundException', () {
      final path = '${tempDir.path}/missing.json';

      expect(
        () => JsonData.fromFile(path, buildDto: _unusedBuildDto),
        throwsA(isA<SettingsNotFoundException>()),
      );
    });

    test('invalid UTF-8 file throws FileReadException', () {
      final path = '${tempDir.path}/invalid_utf8.json';
      // {"a":"\xff\xfe"}
      File(path).writeAsBytesSync([
        0x7b,
        0x22,
        0x61,
        0x22,
        0x3a,
        0x22,
        0xff,
        0xfe,
        0x22,
        0x7d,
      ]);

      expect(
        () => JsonData.fromFile(path, buildDto: _unusedBuildDto),
        throwsA(isA<FileReadException>()),
      );
    });

    test('unreadable file throws FileReadException', () async {
      final path = '${tempDir.path}/unreadable.json';
      File(path).writeAsStringSync('{"a": "b"}');
      await Process.run('chmod', ['000', path]);

      expect(
        () => JsonData.fromFile(path, buildDto: _unusedBuildDto),
        throwsA(isA<FileReadException>()),
      );
    }, skip: Platform.isWindows);
  });
}
