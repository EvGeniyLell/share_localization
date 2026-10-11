import 'package:share_localization/common/exceptions/app_exception.dart';

class FileReadException implements AppException {
  final String path;
  final String detail;

  const FileReadException(this.path, this.detail);

  @override
  String toString() => 'FileReadException: failed to read "$path": $detail';
}
