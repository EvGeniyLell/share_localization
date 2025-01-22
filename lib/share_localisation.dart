import 'package:share_localisation/use_cases/generation_all_use_case.dart';
import 'package:share_localisation/utils/printer.dart';

final builder = GenerationUseCase.all();

Future<void> gen() async {
  final buildTask = await builder('Settings.json');
  if (buildTask.failed) {
    Printer().log('Build task failed with:\n${buildTask.exception}');
    return;
  }
}
