import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/common/exceptions/app_exception.dart';

class BuildReport {
  final List<BuildLocalizationException> warnings;
  final List<AppException> errors;

  BuildReport(List<AppException> all)
      : warnings = all.whereType<BuildLocalizationException>().toList(),
        errors =
            all.where((e) => e is! BuildLocalizationException).toList();

  bool get hasErrors => errors.isNotEmpty;
}
