class Printer {
  static const debug = false;
  static const _instance = Printer._private();

  factory Printer() => _instance;

  const Printer._private();

  void logError(Object error, {required StackTrace stackTrace}) {
    if (debug) {
      log('Error: $error\nStack trace: $stackTrace');
    }
  }

  void log(String message) {
    print(message);
  }
}
