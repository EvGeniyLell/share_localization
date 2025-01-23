import 'package:meta/meta.dart';
import 'package:share_localization/common/exceptions/app_exception.dart';

@immutable
class BuildLocalizationException implements AppException {
  final String? message;
  final BuildLocalizationExceptionType type;

  const BuildLocalizationException(this.type, [this.message]);

  const BuildLocalizationException.missingIosSettings([
    String? message = 'settings are not provided or corrupted',
  ]) : this(BuildLocalizationExceptionType.missingIosSettings, message);

  const BuildLocalizationException.missingAndroidSettings([
    String? message = 'settings are not provided or corrupted',
  ]) : this(BuildLocalizationExceptionType.missingAndroidSettings, message);

  const BuildLocalizationException.missingFlutterSettings([
    String? message = 'settings are not provided or corrupted',
  ]) : this(BuildLocalizationExceptionType.missingFlutterSettings, message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildLocalizationException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          type == other.type;

  @override
  int get hashCode => message.hashCode ^ type.hashCode;

  @override
  String toString() {
    return '$BuildLocalizationException: ${type.name}'
        '${message != null ? ', message: $message' : ''}';
  }
}

enum BuildLocalizationExceptionType {
  missingIosSettings,
  missingAndroidSettings,
  missingFlutterSettings,
}
