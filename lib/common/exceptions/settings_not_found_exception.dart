import 'package:share_localization/common/exceptions/app_exception.dart';

class SettingsNotFoundException implements AppException {
  final String path;

  const SettingsNotFoundException(this.path);

  @override
  String toString() =>
      'SettingsNotFoundException: settings file not found at "$path". '
      'Make sure settings.json exists in the working directory, '
      'or use --settings to specify a custom path.';
}
