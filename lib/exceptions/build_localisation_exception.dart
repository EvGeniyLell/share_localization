import 'package:meta/meta.dart';
import 'package:share_localisation/exceptions/app_exception.dart';

@immutable
class BuildLocalisationException implements AppException {
  final String? message;
  final BuildLocalisationExceptionType type;

  const BuildLocalisationException(this.type, [this.message]);

  const BuildLocalisationException.missingIosSettings([
    String? message = 'settings are not provided or corrupted',
  ]) : this(BuildLocalisationExceptionType.missingIosSettings, message);

  const BuildLocalisationException.missingAndroidSettings([
    String? message = 'settings are not provided or corrupted',
  ]) : this(BuildLocalisationExceptionType.missingAndroidSettings, message);

  const BuildLocalisationException.missingFlutterSettings([
    String? message = 'settings are not provided or corrupted',
  ]) : this(BuildLocalisationExceptionType.missingFlutterSettings, message);


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildLocalisationException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          type == other.type;

  @override
  int get hashCode => message.hashCode ^ type.hashCode;

  @override
  String toString() {
    return '$BuildLocalisationException: ${type.name}'
        '${message != null ? ', message: $message' : ''}';
  }
}

enum BuildLocalisationExceptionType {
  missingIosSettings,
  missingAndroidSettings,
  missingFlutterSettings,
}
