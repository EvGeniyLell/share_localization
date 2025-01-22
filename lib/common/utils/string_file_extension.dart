extension StringFileExtension on String {
  String baseFilename() {
    final parts = split('.');
    if (parts.length < 2) {
      return this;
    }
    return parts.sublist(0, parts.length - 1).join('.');
  }
}
