import 'dart:io';
import 'package:share_localization/code_generation/build_report.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/common/exceptions/app_exception.dart';

class BuildReportPrinter {
  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _yellow = '\x1B[33m';
  static const _green = '\x1B[32m';

  bool get _ansi => stdout.supportsAnsiEscapes;

  String _colour(String code, String text) =>
      _ansi ? '$code$text$_reset' : text;

  void print(BuildReport report) {
    for (final w in report.warnings) {
      Printer().log(_colour(_yellow, '  ⚠  ${w.message ?? w.toString()}'));
    }
    for (final e in report.errors) {
      Printer().err(_colour(_red, '  ✗  $e'));
    }
    if (report.hasErrors) {
      final s = report.errors.length == 1 ? 'error' : 'errors';
      final ws = report.warnings.isEmpty
          ? ''
          : ', ${report.warnings.length} warning${report.warnings.length == 1 ? '' : 's'}';
      Printer().err(_colour(_red, '✗  Build failed — ${report.errors.length} $s$ws'));
    } else if (report.warnings.isNotEmpty) {
      final ws = report.warnings.length == 1 ? 'warning' : 'warnings';
      Printer().log(_colour(_green, '✓  Build completed with ${report.warnings.length} $ws'));
    } else {
      Printer().log(_colour(_green, '✓  Build completed successfully'));
    }
  }

  void printError(AppException exception) {
    Printer().err(_colour(_red, '✗  $exception'));
  }
}
