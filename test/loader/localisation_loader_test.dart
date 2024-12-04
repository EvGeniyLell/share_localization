import 'package:share_localisation/exceptions/unexpected_exception.dart';
import 'package:share_localisation/localisation_loader.dart';
import 'package:share_localisation/utils/common.dart';
import 'package:test/test.dart';

void main() {
  final loader = LocalisationLoader();
  final data = loader.buildData('test/sources/General.json');

  group('LocalisationLoader', () {
    test('buildKeys', () {
      final result = loader.buildKeys(data.getSub('keys').groupByKeys());
      expect(result, hasLength(3));
    });

    test('buildDto', () {
      final dto = loader.buildDto(data);
      expect(dto.languages, hasLength(2));
      expect(dto.languages.first.abbreviation, 'en');

      expect(dto.keys, hasLength(3));
      expect(dto.keys.first.key, 'login_message');
      expect(dto.keys.first.arguments, hasLength(2));
    });

    test('buildDto 2', () async {
      final dynamic keys = data.map['keys'];
      keys?['login_message'] = {
        'comment': 'Login message',
        'arguments': [
          {'name': 'username', 'type': 'string'},
          {'name': 'password', 'type': 'string'},
        ],
        'localizations-error': {
          'en': {'message': 'Login with {username} and {password}'},
          'es': {'message': 'Iniciar sesión con {username} y {password}'},
        },
      };

      final dtoTask = await runAppTaskSafely(() async {
        return loader.buildDto(data);
      });

      expect(dtoTask.failed, true);
      expect(dtoTask.exception, isA<UnexpectedException>());
    });
  });
}
