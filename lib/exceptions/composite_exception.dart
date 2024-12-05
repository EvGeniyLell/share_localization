import 'app_exception.dart';

class CompositeException implements AppException {
  final List<AppException> exceptions;

  CompositeException(this.exceptions);
}
