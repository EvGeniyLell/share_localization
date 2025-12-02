/// The extension help transform camelCase to snakeCase string
extension StringCaseTransformExtension on String {
  String capitalize({bool forceLowerCase = false}) {
    if (isEmpty) {
      return this;
    }

    final resBuf = StringBuffer();
    final firstLetter = trim().substring(0, 1);
    final remaining = trim().substring(1);

    resBuf.write(firstLetter.toUpperCase());

    if (forceLowerCase) {
      resBuf.write(remaining.toLowerCase());
    } else {
      resBuf.write(remaining);
    }

    return resBuf.toString();
  }

  String camelCase() {
    if (isEmpty) {
      return this;
    }

    final RegExp expWord = RegExp('([a-zA-Z0-9]+)');
    bool isFirst = true;
    return expWord
        .allMatches(this)
        .map((m) {
          final word = m.group(0)?.toLowerCase();
          if (word != null) {
            if (isFirst) {
              isFirst = false;
              return word;
            } else {
              return word.capitalize();
            }
          }
        })
        .whereType<String>()
        .join();
  }

  String snakeCase() {
    if (isEmpty) {
      return this;
    }

    final RegExp expWord = RegExp('([a-zA-Z0-9]+)');
    return expWord
        .allMatches(this)
        .map((m) {
          final word = m.group(0)?.toLowerCase();
          return word;
        })
        .whereType<String>()
        .join('_');
  }

  // TODO(evg): consider to remove this method
  String pad(int shift) {
    if (isEmpty || shift == 0) {
      return this;
    }

    return split('\n')
        .map((s) {
          if (shift > 0) {
            return ''.padLeft(shift) + s;
          } else {
            return s.replaceFirst(RegExp('^\\s{0,${-shift}}'), '');
          }
        })
        .join('\n');
  }
}
