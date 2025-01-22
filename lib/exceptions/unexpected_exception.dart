import 'package:share_localization/exceptions/app_exception.dart';

class UnexpectedException implements AppException {
  final String message;

  UnexpectedException(this.message);

  @override
  String toString() {
    return '$UnexpectedException: $message';
  }
}
