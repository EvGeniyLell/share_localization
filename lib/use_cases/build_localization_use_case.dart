import 'dart:io';

import 'package:share_localization/dtos/dtos.dart';
import 'package:share_localization/utils/common.dart';
import 'package:share_localization/utils/file_extension.dart';

export 'package:share_localization/dtos/dtos.dart';
export 'package:share_localization/utils/common.dart';
export 'package:share_localization/utils/file_extension.dart';

abstract class BuildLocalizationUseCase {
  const BuildLocalizationUseCase();

  AppTask<void> call(SettingsDto settings, LocalizationDto localization);

  Future<void> createFile(String path, String content) async {
    final file = File(path).applyCurrentPath();
    await file.create(recursive: true);
    await file.writeAsString(content, flush: true);
  }
}
