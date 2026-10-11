import 'package:share_localization/code_generation/code_generation.dart';

Future<bool> run({String settingsPath = 'settings.json'}) async {
  final builder = BatchCodeGenerationUseCase.all();
  final buildTask = await builder(settingsPath);
  if (buildTask.failed) {
    BuildReportPrinter().printError(buildTask.exception);
    return false;
  }
  final report = buildTask.data;
  BuildReportPrinter().print(report);
  return !report.hasErrors;
}
