abstract class LoggerService {
  void debug(String message);
  void error(String message, {Object? error, StackTrace? stackTrace});
}
