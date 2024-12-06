class Printer {
  static const _instance = Printer._private();

  factory Printer() => _instance;

  const Printer._private();

  void logError(Object error, {required StackTrace stackTrace}) {
    print('Error: $error\nStack trace: $stackTrace');
  }
}
