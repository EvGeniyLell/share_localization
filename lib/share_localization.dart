import 'package:share_localization/code_generation/code_generation.dart';
import 'package:share_localization/common/common.dart';

final builder = BatchCodeGenerationUseCase.all();

Future<void> gen() async {
  final buildTask = await builder('Settings.json');
  if (buildTask.failed) {
    Printer().log('Build task failed with:\n${buildTask.exception}');
    return;
  }
}
