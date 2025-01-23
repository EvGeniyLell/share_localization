import 'dart:io';

import 'package:meta/meta.dart';

class Printer {
  @visibleForTesting
  static void Function(Object? object) output = stdout.writeln;

  @visibleForTesting
  static bool debug = false;

  static const _instance = Printer._private();

  factory Printer() => _instance;

  const Printer._private();

  void logError(Object error, {required StackTrace stackTrace}) {
    if (debug) {
      log('Error: $error\nStack trace: $stackTrace');
    }
  }

  void log(String message) {
    output(message);
  }
}
