import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:share_localization/common/common.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late Directory Function() originalGetCurrentDirectory;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('file_service_test_');
    originalGetCurrentDirectory = FileServiceHelper.getCurrentDirectory;
    // getCurrentPath prepends the current directory, so point it at the temp
    // dir and pass '.' as the path to address it.
    FileServiceHelper.getCurrentDirectory = () => tempDir;
  });

  tearDown(() async {
    FileServiceHelper.getCurrentDirectory = originalGetCurrentDirectory;
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('FileService.getFilesInDirectory', () {
    test(
      'returns matching files sorted by path, skipping directories',
      () async {
        // Created in non-alphabetical order.
        for (final name in [
          'zeta.json',
          'alpha.json',
          'mid.json',
          'beta.json',
          'gamma.json',
          'x.txt',
        ]) {
          await File(p.join(tempDir.path, name)).writeAsString('{}');
        }
        await Directory(p.join(tempDir.path, 'sub.json')).create();

        final files = await const FileService().getFilesInDirectory(
          path: '.',
          extension: '.json',
        );

        final basenames = files.map((f) => p.basename(f.path)).toList();
        expect(basenames, [
          'alpha.json',
          'beta.json',
          'gamma.json',
          'mid.json',
          'zeta.json',
        ]);
      },
    );

    test('filters by extension', () async {
      await File(p.join(tempDir.path, 'a.json')).writeAsString('{}');
      await File(p.join(tempDir.path, 'b.txt')).writeAsString('');

      final txt = await const FileService().getFilesInDirectory(
        path: '.',
        extension: '.txt',
      );
      final json = await const FileService().getFilesInDirectory(
        path: '.',
        extension: '.json',
      );

      expect(txt.map((f) => p.basename(f.path)), ['b.txt']);
      expect(json.map((f) => p.basename(f.path)), ['a.json']);
    });
  });
}
