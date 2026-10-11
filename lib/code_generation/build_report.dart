import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';

class BuildReport {
  final List<AppException> warnings;
  final List<AppException> errors;

  BuildReport(List<AppException> all)
      : warnings = all.where(_isWarning).toList(),
        errors = all.where((e) => !_isWarning(e)).toList();

  static bool _isWarning(AppException e) =>
      e is BuildLocalizationException ||
      e is VerificationLocalizationException;

  bool get hasErrors => errors.isNotEmpty;
}
