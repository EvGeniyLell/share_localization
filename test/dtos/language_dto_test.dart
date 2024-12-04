

import 'package:test/test.dart';
import 'mock.dart';

void main() {
  final jsonData = JsonData.filepath('test/sources/General.json');

  test('LanguageDto fromJsonData', () {
    final List<String> raw = jsonData.getList('languages');
    expect(raw, ['en', 'de']);

    final List<LanguageDto> languages = jsonData.getMapList(
      'languages',
      transform: LanguageDto.fromJsonData,
    );
    expect(languages, [
      LanguageDto(abbreviation: 'en'),
      LanguageDto(abbreviation: 'de'),
    ]);
  });
}
