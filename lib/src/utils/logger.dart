/// A simple logger utility that allows logging messages using a provided logging function.
class Logger {
  /// Creates a new instance of [Logger] with an optional logging function.
  Logger(this._logFunction);

  /// The logging function to be used for logging messages.
  final void Function(String message)? _logFunction;

  /// Logs a message using the provided logging function, if available.
  void log(String Function() message) {
    _logFunction?.call(message());
  }
}
