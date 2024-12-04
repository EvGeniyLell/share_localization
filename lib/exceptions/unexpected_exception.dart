import 'app_exception.dart';

class UnexpectedException implements AppException {
  final String message;

  UnexpectedException(this.message);
}
