import 'package:share_localisation/exceptions/exceptions.dart';
import 'package:share_localisation/use_cases/localisation_loader_use_case.dart';
import 'package:share_localisation/utils/common.dart';
import 'package:test/test.dart';

void main() {
  final loader = LocalisationLoaderUseCase();
  final data = loader.buildData('test/sources/General.json');

  group('LocalisationLoader', () {
    test('getLocalisationDto', () {
      final dto = data.getLocalisationDto();
      expect(dto.languages, hasLength(2));
      expect(dto.languages.first.abbreviation, 'en');

      expect(dto.keys, hasLength(3));
      expect(dto.keys.first.key, 'login_message');
      expect(dto.keys.first.arguments, hasLength(2));
    });

    test('exception', () async {
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
        return data.getLocalisationDto();
      });

      expect(dtoTask.failed, true);
      expect(dtoTask.exception, isA<UnexpectedException>());
    });
  });
}
