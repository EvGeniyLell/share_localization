import 'package:share_localization/common/common.dart';
import 'package:test/test.dart';

void main() {
  final printer = Printer();
  late List<Object?> out;
  late List<Object?> err;

  setUp(() {
    out = [];
    err = [];
    Printer.output = out.add;
    Printer.errorOutput = err.add;
    Printer.debug = false;
  });

  tearDown(() {
    Printer.debug = false;
  });

  group('Printer', () {
    test('log writes to output only', () {
      printer.log('hello');

      expect(out, ['hello']);
      expect(err, isEmpty);
    });

    test('err writes to errorOutput only, regardless of debug', () {
      printer.err('first');
      Printer.debug = true;
      printer.err('second');

      expect(err, ['first', 'second']);
      expect(out, isEmpty);
    });

    test('logError is silent when debug is off', () {
      printer.logError('boom', stackTrace: StackTrace.current);

      expect(err, isEmpty);
      expect(out, isEmpty);
    });

    test('logError writes error and stack trace to errorOutput in debug', () {
      Printer.debug = true;
      printer.logError('boom', stackTrace: StackTrace.fromString('trace'));

      expect(err, ['Error: boom\nStack trace: trace']);
      expect(out, isEmpty);
    });
  });

  group('runAppTaskSafely', () {
    test('does not print a failure, so callers report it once', () async {
      final task = await runAppTaskSafely<void>(() => throw StateError('x'));

      expect(task.failed, true);
      expect(err, isEmpty);
      expect(out, isEmpty);
    });
  });
}
