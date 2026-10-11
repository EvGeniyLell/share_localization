import 'package:share_localization/code_generation/build_report.dart';
import 'package:share_localization/code_generation/exceptions/build_localization_exception.dart';
import 'package:share_localization/code_generation/use_cases/build_report_printer.dart';
import 'package:share_localization/common/common.dart';
import 'package:test/test.dart';

class _FakeBuildError implements AppException {
  final String text;

  const _FakeBuildError(this.text);

  @override
  String toString() => text;
}

final _ansi = RegExp(r'\x1B\[[0-9;]*m');

String _plain(Object? line) => '$line'.replaceAll(_ansi, '');

void main() {
  late List<String> out;
  late List<String> err;
  late void Function(Object?) originalOutput;
  late void Function(Object?) originalErrorOutput;

  setUp(() {
    out = [];
    err = [];
    originalOutput = Printer.output;
    originalErrorOutput = Printer.errorOutput;
    Printer.output = (line) => out.add(_plain(line));
    Printer.errorOutput = (line) => err.add(_plain(line));
  });

  tearDown(() {
    Printer.output = originalOutput;
    Printer.errorOutput = originalErrorOutput;
  });

  const warning = BuildLocalizationException.missingIosSettings(
    'iOS generation skipped.',
  );
  const otherWarning = BuildLocalizationException.missingAndroidSettings(
    'Android generation skipped.',
  );
  const error = _FakeBuildError('Something broke');
  const otherError = _FakeBuildError('Something else broke');

  group('BuildReportPrinter.print', () {
    test('no warnings or errors prints the success line only', () {
      BuildReportPrinter().print(BuildReport([]));

      expect(out, ['✓  Build completed successfully']);
      expect(err, isEmpty);
    });

    test('one warning prints the warning then a singular summary', () {
      BuildReportPrinter().print(BuildReport([warning]));

      expect(out, [
        '  ⚠  iOS generation skipped.',
        '✓  Build completed with 1 warning',
      ]);
      expect(err, isEmpty);
    });

    test('two warnings print the plural summary', () {
      BuildReportPrinter().print(BuildReport([warning, otherWarning]));

      expect(out, [
        '  ⚠  iOS generation skipped.',
        '  ⚠  Android generation skipped.',
        '✓  Build completed with 2 warnings',
      ]);
      expect(err, isEmpty);
    });

    test('one error and no warnings prints the singular failure summary', () {
      BuildReportPrinter().print(BuildReport([error]));

      expect(out, isEmpty);
      expect(err, ['  ✗  Something broke', '✗  Build failed — 1 error']);
    });

    test(
      'two errors and one warning print the warning count in the failure',
      () {
        BuildReportPrinter().print(BuildReport([warning, error, otherError]));

        expect(out, ['  ⚠  iOS generation skipped.']);
        expect(err, [
          '  ✗  Something broke',
          '  ✗  Something else broke',
          '✗  Build failed — 2 errors, 1 warning',
        ]);
      },
    );

    test('two errors and two warnings print the plural warning count', () {
      BuildReportPrinter().print(
        BuildReport([warning, otherWarning, error, otherError]),
      );

      expect(out, [
        '  ⚠  iOS generation skipped.',
        '  ⚠  Android generation skipped.',
      ]);
      expect(err, [
        '  ✗  Something broke',
        '  ✗  Something else broke',
        '✗  Build failed — 2 errors, 2 warnings',
      ]);
    });

    test('warning without a message falls back to its toString', () {
      BuildReportPrinter().print(
        BuildReport([
          const BuildLocalizationException(
            BuildLocalizationExceptionType.missingFlutterSettings,
          ),
        ]),
      );

      expect(out, [
        '  ⚠  BuildLocalizationException: missingFlutterSettings',
        '✓  Build completed with 1 warning',
      ]);
      expect(err, isEmpty);
    });
  });

  group('BuildReportPrinter.printError', () {
    test('prints the exception with the error prefix to the error output', () {
      BuildReportPrinter().printError(error);

      expect(out, isEmpty);
      expect(err, ['✗  Something broke']);
    });
  });

  group('BuildReportPrinter colour per stream', () {
    const yellow = '\x1B[33m';
    const green = '\x1B[32m';
    const red = '\x1B[31m';
    const reset = '\x1B[0m';
    const noEnv = <String, String>{};
    const noColourEnv = <String, String>{'NO_COLOR': '1'};
    const emptyNoColourEnv = <String, String>{'NO_COLOR': ''};
    const warnLine = '  ⚠  iOS generation skipped.';
    const errLine = '  ✗  Something broke';
    const failLine = '✗  Build failed — 1 error, 1 warning';
    const successLine = '✓  Build completed successfully';
    const warnSummary = '✓  Build completed with 1 warning';

    late List<String> rawOut;
    late List<String> rawErr;

    setUp(() {
      rawOut = [];
      rawErr = [];
      Printer.output = (line) => rawOut.add('$line');
      Printer.errorOutput = (line) => rawErr.add('$line');
    });

    test('(a) stdout on, stderr off: stdout coloured, stderr plain', () {
      BuildReportPrinter(
        stdoutAnsi: true,
        stderrAnsi: false,
        environment: noEnv,
      ).print(BuildReport([warning, error]));

      expect(rawOut, ['$yellow$warnLine$reset']);
      expect(rawErr, [errLine, failLine]);
    });

    test('(a) stdout on, stderr off: warnings-only report is coloured', () {
      BuildReportPrinter(
        stdoutAnsi: true,
        stderrAnsi: false,
        environment: noEnv,
      ).print(BuildReport([warning]));

      expect(rawOut, ['$yellow$warnLine$reset', '$green$warnSummary$reset']);
      expect(rawErr, isEmpty);
    });

    test('(a) stdout on, stderr off: success line is coloured', () {
      BuildReportPrinter(
        stdoutAnsi: true,
        stderrAnsi: false,
        environment: noEnv,
      ).print(BuildReport([]));

      expect(rawOut, ['$green$successLine$reset']);
      expect(rawErr, isEmpty);
    });

    test('(b) stdout off, stderr on: error lines and failure are red', () {
      BuildReportPrinter(
        stdoutAnsi: false,
        stderrAnsi: true,
        environment: noEnv,
      ).print(BuildReport([warning, error]));

      expect(rawOut, [warnLine]);
      expect(rawErr, ['$red$errLine$reset', '$red$failLine$reset']);
    });

    test('(c) both on: warning and error report is exactly coloured', () {
      BuildReportPrinter(
        stdoutAnsi: true,
        stderrAnsi: true,
        environment: noEnv,
      ).print(BuildReport([warning, error]));

      expect(rawOut, ['$yellow$warnLine$reset']);
      expect(rawErr, ['$red$errLine$reset', '$red$failLine$reset']);
    });

    test('(c) both on: success report is green', () {
      BuildReportPrinter(
        stdoutAnsi: true,
        stderrAnsi: true,
        environment: noEnv,
      ).print(BuildReport([]));

      expect(rawOut, ['$green$successLine$reset']);
      expect(rawErr, isEmpty);
    });

    test('(c) both on: warnings-only report is yellow then green', () {
      BuildReportPrinter(
        stdoutAnsi: true,
        stderrAnsi: true,
        environment: noEnv,
      ).print(BuildReport([warning]));

      expect(rawOut, ['$yellow$warnLine$reset', '$green$warnSummary$reset']);
      expect(rawErr, isEmpty);
    });

    test('(d) printError follows the stderr flag, not stdout', () {
      BuildReportPrinter(
        stdoutAnsi: true,
        stderrAnsi: false,
        environment: noEnv,
      ).printError(error);

      expect(rawErr, ['✗  Something broke']);
    });

    test('(d) printError is red when only stderr supports colour', () {
      BuildReportPrinter(
        stdoutAnsi: false,
        stderrAnsi: true,
        environment: noEnv,
      ).printError(error);

      expect(rawErr, ['$red✗  Something broke$reset']);
    });

    test('(e) NO_COLOR set disables colour even when both are on', () {
      BuildReportPrinter(
        stdoutAnsi: true,
        stderrAnsi: true,
        environment: noColourEnv,
      ).print(BuildReport([warning, error]));
      BuildReportPrinter(
        stdoutAnsi: true,
        stderrAnsi: true,
        environment: noColourEnv,
      ).printError(error);

      expect(rawOut, [warnLine]);
      expect(rawErr, [errLine, failLine, '✗  Something broke']);
    });

    test('(e) empty NO_COLOR does not disable colour', () {
      BuildReportPrinter(
        stdoutAnsi: true,
        stderrAnsi: true,
        environment: emptyNoColourEnv,
      ).print(BuildReport([]));

      expect(rawOut, ['$green$successLine$reset']);
    });

    test('(e) environment without NO_COLOR keeps colour on', () {
      BuildReportPrinter(
        stdoutAnsi: true,
        stderrAnsi: true,
        environment: const {'TERM': 'xterm'},
      ).print(BuildReport([]));

      expect(rawOut, ['$green$successLine$reset']);
    });

    test('(f) both off: everything is plain', () {
      BuildReportPrinter(
        stdoutAnsi: false,
        stderrAnsi: false,
        environment: noEnv,
      ).print(BuildReport([warning, error]));

      expect(rawOut, [warnLine]);
      expect(rawErr, [errLine, failLine]);
    });
  });
}
