import 'dart:io';

import 'package:meta/meta.dart';

class FileService {
  const FileService();

  Future<void> createFile({
    required String path,
    required String content,
  }) async {
    final currentPath = FileServiceHelper.getCurrentPath(path);
    final file = File(currentPath);
    await file.create(recursive: true);
    await file.writeAsString(content, flush: true);
  }

  /// Returns the files in [path] whose path ends with [extension], sorted
  /// ascending by [File.path].
  ///
  /// The order is made explicit because `listSync()` returns entries in
  /// filesystem-dependent order, which would otherwise make bundle load order
  /// (and therefore generated output) non-deterministic across machines.
  Future<List<File>> getFilesInDirectory({
    required String path,
    required String extension,
  }) async {
    final currentPath = FileServiceHelper.getCurrentPath(path);
    return Directory(currentPath)
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith(extension))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }
}

@visibleForTesting
extension FileServiceHelper on FileService {
  static Directory Function() getCurrentDirectory = () => Directory.current;

  static String getCurrentPath(String path) {
    final currentPath = getCurrentDirectory().path;
    final pathItems = path.split('/');
    final currentPathItems = currentPath.split('/');

    while (pathItems.firstOrNull == '..') {
      pathItems.removeAt(0);
      if (currentPathItems.isEmpty) {
        throw ArgumentError('Path $path is invalid');
      }
      currentPathItems.removeAt(currentPathItems.length - 1);
    }

    return [...currentPathItems, ...pathItems].join('/');
  }
}
