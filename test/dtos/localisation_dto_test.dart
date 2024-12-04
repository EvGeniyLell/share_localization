import 'package:share_localisation/dtos/localisation_dto.dart';
import 'package:test/test.dart';

import 'mock.dart';

void main() {
  final jsonData = JsonData.filepath('test/sources/General.json');

  test('LocalisationDto fromJsonData', () {
    final dto = LocalisationDto.fromJsonData(jsonData);

    expect(dto.languages, hasLength(2));
    expect(dto.keys, hasLength(3));
  });
}
