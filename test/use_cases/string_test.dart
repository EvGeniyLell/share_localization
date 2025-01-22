import 'package:share_localization/utils/string_case_transform_extension.dart';
import 'package:test/test.dart';

void main() {
  group('String', () {
    group('pad', () {
      const source0 = '''
line1: {
line1.1,
line1.2
},  
line3''';
      const source1 = '''
line1: {
  line1.1,
  line1.2
},  
line3''';
      const source2 = '''
    line1: {
      line1.1,
      line1.2
    },  
    line3''';
      test('pad - add 4', () {
        final result = source1.pad(4);
        expect(result, source2);
      });
      test('pad - remove 4', () {
        final result = source2.pad(-4);
        expect(result, source1);
      });
      test('pad - over remove', () {
        final result = source2.pad(-6);
        expect(result, source0);
      });
    });
  });
}
