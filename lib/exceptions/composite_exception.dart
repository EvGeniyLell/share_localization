import 'package:share_localization/exceptions/app_exception.dart';

class CompositeException implements AppException {
  final List<AppException> exceptions;

  CompositeException(this.exceptions);

  @override
  String toString() {
    return exceptions.map((e) => e.toString()).join('\n');
  }
}
