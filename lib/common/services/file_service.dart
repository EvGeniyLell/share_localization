import 'dart:io';

import 'package:meta/meta.dart';

class FileService {
  const FileService();

  Future<void> createFile({
    required String path,
    required String content,
  }) async {
    final file = File(path).applyCurrentPath();
    await file.create(recursive: true);
    await file.writeAsString(content, flush: true);
  }
}

@visibleForTesting
extension FileExtension on File {
  File applyCurrentPath() {
    final currentPath = Directory.current.path;
    final pathItems = path.split('/');
    final currentPathItems = currentPath.split('/');

    while (pathItems.firstOrNull == '..') {
      pathItems.removeAt(0);
      if (currentPathItems.isEmpty) {
        throw ArgumentError('Path $path is invalid');
      }
      currentPathItems.removeAt(currentPathItems.length - 1);
    }

    return File([...currentPathItems, ...pathItems].join('/'));
  }
}
