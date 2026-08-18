import 'dart:io';

import 'package:share_localization/common/common.dart';
import 'package:share_localization/share_localization.dart'
    as share_localization;

Future<void> main(List<String> arguments) async {
  var settingsPath = 'settings.json';
  var verbose = false;

  for (var i = 0; i < arguments.length; i++) {
    final arg = arguments[i];
    switch (arg) {
      case '--help':
      case '-h':
        _printHelp();
        return;
      case '--version':
        stdout.writeln('share_localization $appVersion');
        return;
      case '--verbose':
        verbose = true;
      case '--settings':
        if (i + 1 < arguments.length) {
          settingsPath = arguments[++i];
        } else {
          stderr.writeln('Error: --settings requires a path argument.');
          exit(1);
        }
      default:
        stderr.writeln('Unknown option: $arg');
        _printHelp();
        exit(1);
    }
  }

  if (verbose) {
    Printer.debug = true;
  }

  final success = await share_localization.run(settingsPath: settingsPath);
  if (!success) {
    exit(1);
  }
}

void _printHelp() {
  stdout.writeln('''
Usage: share_localization [options]

Options:
  -h, --help              Show this help message and exit
  --version               Show the tool version and exit
  --verbose               Enable verbose output with stack traces
  --settings <path>       Path to settings.json (default: settings.json)

The tool reads <settings.json> from the current working directory by default
and generates platform-native localisation files for iOS, Flutter, and Android.
''');
}
