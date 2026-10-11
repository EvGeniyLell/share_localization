import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';

class BuildReport {
  final List<AppException> warnings;
  final List<AppException> errors;

  BuildReport(List<AppException> all)
    // A Set keeps first-seen order, so equal warnings from several bundles
    // (e.g. the same missing "ios" block) are reported once.
    : warnings = all.where(_isWarning).toSet().toList(),
      errors = all.where((e) => !_isWarning(e)).toList();

  static bool _isWarning(AppException e) =>
      e is BuildLocalizationException || e is VerificationLocalizationException;

  bool get hasErrors => errors.isNotEmpty;
}
