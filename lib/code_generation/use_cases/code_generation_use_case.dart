import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';
import 'package:share_localization/settings/settings.dart';

abstract class CodeGenerationUseCase {
  final FileService fileService;

  const CodeGenerationUseCase(this.fileService);

  Task<void> call(SettingsDto settings, LocalizationDto localization);
}
