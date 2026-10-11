import 'dart:io';

import 'package:meta/meta.dart';

class Printer {
  @visibleForTesting
  static void Function(Object? object) output = stdout.writeln;

  @visibleForTesting
  static void Function(Object? object) errorOutput = stderr.writeln;

  static bool debug = false;

  static const _instance = Printer._private();

  factory Printer() => _instance;

  const Printer._private();

  /// Prints error details (with the stack trace) to stderr in debug mode only.
  ///
  /// The user-facing error message is printed once by the caller via [err],
  /// otherwise nested tasks would repeat it at every level.
  void logError(Object error, {required StackTrace stackTrace}) {
    if (debug) {
      err('Error: $error\nStack trace: $stackTrace');
    }
  }

  void log(String message) {
    output(message);
  }

  void err(String message) {
    errorOutput(message);
  }
}
