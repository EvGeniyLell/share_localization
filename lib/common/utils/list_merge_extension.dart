extension ListMergeExtension<E> on List<E> {
  /// Return tuple of intersection of two lists,
  /// - `$1`: for items presents only in `left` list,
  /// - `$2`: for common,
  /// - `$3`: for items presents only in `right` list.
  (List<E> left, List<E> common, List<E> righ) intersection(
    List<E> other, {
    bool Function(E l, E r)? test,
  }) {
    final resolvedTest = test ?? (l, r) => l == r;
    final common = {
      ...this,
      ...other,
    };
    final onlyLeft = mapWhereEvery(
      other,
      test: (l, r) => !resolvedTest(l, r),
      toElement: (e) {
        common.remove(e);
        return e;
      },
    );
    final onlyRight = other.mapWhereEvery(
      this,
      test: (l, r) => !resolvedTest(l, r),
      toElement: (e) {
        common.remove(e);
        return e;
      },
    );
    return (onlyLeft.toList(), common.toList(), onlyRight.toList());
  }

  /// Return a new list with `every elements` that satisfy the [test]
  /// and mapped to [R] type.
  List<R> mapWhereEvery<R, EE>(
    List<EE> other, {
    required bool Function(E l, EE r) test,
    required R Function(E e) toElement,
  }) {
    return map((lItem) {
      final has = other.every((rItem) => test(lItem, rItem));
      return has ? toElement(lItem) : null;
    }).whereType<R>().toList();
  }

  /// Return a new list with `any elements` that satisfy the [test]
  /// and mapped to [R] type.
  List<R> mapWhereAny<R, EE>(
    List<EE> other, {
    required bool Function(E l, EE r) test,
    required R Function(E e) toElement,
  }) {
    return map((lItem) {
      final has = other.any((rItem) => test(lItem, rItem));
      return has ? toElement(lItem) : null;
    }).whereType<R>().toList();
  }
}
