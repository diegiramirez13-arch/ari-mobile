import 'dart:developer' as developer;

class LoggerService {
  static void info(String message, {String tag = 'ARI_INFO'}) {
    developer.log(message, name: tag);
  }

  static void error(
    String message,
    dynamic error, {
    StackTrace? stackTrace,
    String tag = 'ARI_ERROR',
  }) {
    developer.log(
      message,
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
    // Aquí a futuro se conecta Crashlytics:
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message);
  }
}
