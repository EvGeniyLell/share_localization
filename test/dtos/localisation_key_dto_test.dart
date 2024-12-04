import 'package:test/test.dart';

import 'mock.dart';

void main() {
  final jsonData = JsonData.filepath('test/sources/General.json');

  test('LocalisationKeyDto fromJsonData', () {
    final JsonData keysData = jsonData.getMap('keys', transform: (data) {
      return data;
    });
    expect(keysData.path, 'root/keys');

    final List<LocalisationKeyDto> dtos = jsonData.getMapWithKeys(
      'keys',
      transform: LocalisationKeyDto.fromJsonData,
    );
    expect(dtos.first, loginMessageKey);
  });
}
