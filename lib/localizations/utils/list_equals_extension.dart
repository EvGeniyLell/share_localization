extension ListEqualsExtension<E> on List<E> {
  bool equals(List<E> list) {
    if (length != list.length) {
      return false;
    }
    return every((item) => list.contains(item));
  }

  bool equalsBy(List<E> list, bool Function(E, E) equals) {
    if (length != list.length) {
      return false;
    }
    return every((l) => list.any((r) => equals(l, r)));
  }
}