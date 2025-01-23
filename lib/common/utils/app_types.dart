typedef JsonMap = Map<String, Object?>;

extension NullObjectSageExtension<O extends Object?> on O {
  T nullSafe<T>(T Function(O) fn) => fn(this);
}
