import 'package:test/test.dart';

import 'mock.dart';

void main() {
  final jsonData = JsonData.filepath('test/sources/General.json');

  test('LocalisationKeyArgumentDto fromJsonData', () {
    final JsonData keysData = jsonData.getMap('keys', transform: (data) {
      return data;
    });
    expect(keysData.path, 'root/keys');

    final JsonData loginMessageData = keysData.getMap(
      'login_message',
      transform: (data) {
        data.map['key'] = 'login_message';
        return data;
      },
    );
    expect(loginMessageData.path, 'root/keys/login_message');

    final List<LocalisationKeyArgumentDto> dtos = loginMessageData.getMapList(
      'arguments',
      transform: LocalisationKeyArgumentDto.fromJsonData,
    );
    expect(dtos, loginMessageKeyArguments);
  });
}
