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
}
