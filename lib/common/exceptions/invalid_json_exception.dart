import 'package:share_localization/common/exceptions/app_exception.dart';

class InvalidJsonException implements AppException {
  final String path;
  final String detail;

  const InvalidJsonException(this.path, this.detail);

  @override
  String toString() =>
      'InvalidJsonException: failed to parse "$path": $detail';
}
