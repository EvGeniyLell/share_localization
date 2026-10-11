import 'dart:io';
import 'package:share_localization/code_generation/build_report.dart';
import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/common/common.dart';
import 'package:share_localization/localizations/localizations.dart';

class BuildReportPrinter {
  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _yellow = '\x1B[33m';
  static const _green = '\x1B[32m';

  bool get _ansi => stdout.supportsAnsiEscapes;

  String _colour(String code, String text) =>
      _ansi ? '$code$text$_reset' : text;

  void print(BuildReport report) {
    final errorCount = report.errors.length;
    final warningCount = report.warnings.length;
    for (final w in report.warnings) {
      Printer().log(_colour(_yellow, '  ⚠  ${_warningText(w)}'));
    }
    for (final e in report.errors) {
      Printer().err(_colour(_red, '  ✗  $e'));
    }
    if (report.hasErrors) {
      final warnings = _count(warningCount, 'warning');
      final suffix = warningCount > 0 ? ', $warnings' : '';
      final summary = '${_count(errorCount, 'error')}$suffix';
      Printer().err(_colour(_red, '✗  Build failed — $summary'));
    } else if (warningCount > 0) {
      final summary = _count(warningCount, 'warning');
      Printer().log(_colour(_green, '✓  Build completed with $summary'));
    } else {
      Printer().log(_colour(_green, '✓  Build completed successfully'));
    }
  }

  /// Formats `count` with [noun], pluralised unless the count is exactly 1.
  static String _count(int count, String noun) {
    final word = count == 1 ? noun : '${noun}s';
    return '$count $word';
  }

  String _warningText(AppException warning) {
    return switch (warning) {
      VerificationLocalizationException(:final message) => message,
      BuildLocalizationException(:final message) => message ?? '$warning',
      _ => '$warning',
    };
  }

  void printError(AppException exception) {
    Printer().err(_colour(_red, '✗  $exception'));
  }
}
