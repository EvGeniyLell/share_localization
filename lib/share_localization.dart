import 'package:share_localization/code_generation/code_generation.dart';
import 'package:share_localization/common/common.dart';

final builder = BatchCodeGenerationUseCase.all();

Future<void> run() async {
  final buildTask = await builder('settings.json');
  Printer().log('Build task finished');
  if (buildTask.failed) {
    Printer().log('with:\n${buildTask.exception}');
    return;
  }
}
