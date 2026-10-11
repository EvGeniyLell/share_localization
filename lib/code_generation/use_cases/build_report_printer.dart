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

  BuildReportPrinter({
    bool? stdoutAnsi,
    bool? stderrAnsi,
    Map<String, String>? environment,
  }) : _stdoutAnsi = stdoutAnsi,
       _stderrAnsi = stderrAnsi,
       _environment = environment;

  final bool? _stdoutAnsi;
  final bool? _stderrAnsi;
  final Map<String, String>? _environment;

  /// https://no-color.org: a non-empty NO_COLOR disables colour everywhere.
  bool get _noColourRequested {
    final value = (_environment ?? Platform.environment)['NO_COLOR'];
    return value != null && value.isNotEmpty;
  }

  bool get _stdoutColour =>
      !_noColourRequested && (_stdoutAnsi ?? stdout.supportsAnsiEscapes);

  bool get _stderrColour =>
      !_noColourRequested && (_stderrAnsi ?? stderr.supportsAnsiEscapes);

  /// Colours [text] using the capability of the stream it is written to.
  String _colour(String code, String text, {required bool toStderr}) {
    final ansi = toStderr ? _stderrColour : _stdoutColour;
    return ansi ? '$code$text$_reset' : text;
  }

  void print(BuildReport report) {
    final errorCount = report.errors.length;
    final warningCount = report.warnings.length;
    for (final w in report.warnings) {
      Printer().log(
        _colour(_yellow, '  ⚠  ${_warningText(w)}', toStderr: false),
      );
    }
    for (final e in report.errors) {
      Printer().err(_colour(_red, '  ✗  $e', toStderr: true));
    }
    if (report.hasErrors) {
      final warnings = _count(warningCount, 'warning');
      final suffix = warningCount > 0 ? ', $warnings' : '';
      final summary = '${_count(errorCount, 'error')}$suffix';
      Printer().err(
        _colour(_red, '✗  Build failed — $summary', toStderr: true),
      );
    } else if (warningCount > 0) {
      final summary = _count(warningCount, 'warning');
      Printer().log(
        _colour(_green, '✓  Build completed with $summary', toStderr: false),
      );
    } else {
      Printer().log(
        _colour(_green, '✓  Build completed successfully', toStderr: false),
      );
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
    Printer().err(_colour(_red, '✗  $exception', toStderr: true));
  }
}
