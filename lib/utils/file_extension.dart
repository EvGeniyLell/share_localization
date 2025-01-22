import 'dart:io';

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

extension StringFileExtension on String {
  String baseFilename() {
    final parts = split('.');
    if (parts.length < 2) {
      return this;
    }
    return parts.sublist(0, parts.length - 1).join('.');
  }
}