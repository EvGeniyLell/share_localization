import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  group('camelCase', () {
    test('should be loadPass', () {
      const expectedResult = 'loadPass';
      expect('LoadPass'.camelCase(), expectedResult);
      expect('loadPass'.camelCase(), expectedResult);
      expect('load_pass'.camelCase(), expectedResult);
      expect('load pass'.camelCase(), expectedResult);
      expect('LOAD PASS'.camelCase(), expectedResult);
    });

    test('additional', () {
      expect('qrURLCode'.camelCase(), 'qrUrlCode');
      expect('extraDATA'.camelCase(), 'extraData');
      expect('MEGATRON'.camelCase(), 'megatron');
    });
  });

  group('snakeCase', () {
    test('should be load_pass', () {
      const expectedResult = 'load_pass';
      expect('LoadPass'.snakeCase(), expectedResult);
      expect('loadPass'.snakeCase(), expectedResult);
      expect('load_pass'.snakeCase(), expectedResult);
      expect('load pass'.snakeCase(), expectedResult);
      expect('LOAD PASS'.snakeCase(), expectedResult);
    });

    test('additional', () {
      expect('qrURLCode'.snakeCase(), 'qr_url_code');
      expect('extraDATA'.snakeCase(), 'extra_data');
      expect('MEGATRON'.snakeCase(), 'megatron');
    });
  });
}
