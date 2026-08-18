import 'package:share_localization/common/exceptions/app_exception.dart';

class CompositeException implements AppException {
  final List<AppException> exceptions;

  CompositeException(List<AppException> exceptions)
      : exceptions = List.unmodifiable(exceptions);

  @override
  String toString() {
    return exceptions.map((e) => e.toString()).join('\n');
  }
}
