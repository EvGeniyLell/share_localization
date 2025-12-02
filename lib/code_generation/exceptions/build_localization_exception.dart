import 'package:meta/meta.dart';
import 'package:share_localization/common/exceptions/app_exception.dart';

@immutable
class BuildLocalizationException implements AppException {
  final String? message;
  final BuildLocalizationExceptionType type;

  const BuildLocalizationException(this.type, [this.message]);

  static const _defaultMessage =
      'settings are not provided or corrupted, '
      'this location build will be skipped';

  const BuildLocalizationException.missingIosSettings([
    String? message = _defaultMessage,
  ]) : this(BuildLocalizationExceptionType.missingIosSettings, message);

  const BuildLocalizationException.missingAndroidSettings([
    String? message = _defaultMessage,
  ]) : this(BuildLocalizationExceptionType.missingAndroidSettings, message);

  const BuildLocalizationException.missingFlutterSettings([
    String? message = _defaultMessage,
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
