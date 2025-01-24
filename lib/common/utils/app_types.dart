typedef JsonMap = Map<String, Object?>;

extension NullObjectSageExtension<O extends Object?> on O {
  T nullSafe<T>(T Function(O) fn) => fn(this);
}

extension NullStringSageExtension on String? {
  String? nullIfEmpty({bool trim = true}) {
    String? result = this;
    if (result == null) {
      return null;
    }
    if (trim == true) {
      result = result.trim();
    }
    if (result.isEmpty == true) {
      return null;
    }
    return result;
  }
}
