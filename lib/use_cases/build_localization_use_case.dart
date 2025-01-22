import 'dart:io' as io;

import 'package:share_localization/dtos/dtos.dart';
import 'package:share_localization/utils/common.dart';

abstract class BuildLocalizationUseCase {
  const BuildLocalizationUseCase();

  AppTask<void> call(SettingsDto settings, LocalizationDto localization);

  Future<void> createFile(String path, String content) async {
    final file = CurrentPathFile.file(path);
    await file.create(recursive: true);
    await file.writeAsString(content, flush: true);
  }
}

extension CurrentPathFile on io.File {
  static io.File file(String path) {
    final currentPath = io.Directory.current.path;
    final pathItems = path.split('/');
    final currentPathItems = currentPath.split('/');

    while (pathItems.firstOrNull == '..') {
      pathItems.removeAt(0);
      if (currentPathItems.isEmpty) {
        throw ArgumentError('Path $path is invalid');
      }
      currentPathItems.removeAt(currentPathItems.length - 1);
    }

    return io.File([...currentPathItems, ...pathItems].join('/'));
  }
}
