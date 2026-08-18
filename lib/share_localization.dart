import 'package:share_localization/code_generation/code_generation.dart';
import 'package:share_localization/common/common.dart';

Future<bool> run({String settingsPath = 'settings.json'}) async {
  final builder = BatchCodeGenerationUseCase.all();
  final buildTask = await builder(settingsPath);
  Printer().log('Build task finished');
  if (buildTask.failed) {
    Printer().log('with:\n${buildTask.exception}');
    return false;
  }
  return true;
}
