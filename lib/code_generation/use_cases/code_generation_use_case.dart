import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';
import 'package:share_localization/settings/settings.dart';

abstract class CodeGenerationUseCase {
  final FileService fileService;

  const CodeGenerationUseCase(this.fileService);

  Task<void> call(SettingsDto settings, LocalizationDto localization);

  /// Checks one bundle without writing any file. Returns the error [call]
  /// would fail with for the same input, or null. A builder skipped because of
  /// [validateBundles] is still checked this way, so all errors are reported
  /// in one run.
  AppException? validateBundle(
    SettingsDto settings,
    LocalizationDto localization,
  ) => null;

  /// Checks all bundles together before any file is written. A builder whose
  /// output is one namespace across bundles overrides this. Returns the
  /// errors found, or none by default.
  List<AppException> validateBundles(
    SettingsDto settings,
    List<LocalizationDto> localizations,
  ) => const [];
}
