import 'package:app_logger/app_logger.dart';

/// Logger for early startup stages.
///
/// Why a dedicated startup logger:
/// - Bootstrap happens before the UI is ready, so we log to a known sink.
/// - Logging can be toggled via config to avoid noisy startup output.
/// - Prefixes messages so startup logs are easy to spot in mixed streams.
class StartupLogger {
  const StartupLogger({required bool enabled, required AppLogger logger})
    : _enabled = enabled,
      _logger = logger;

  final bool _enabled;
  final AppLogger _logger;

  /// Log an informational startup message when enabled.
  void info(String message) {
    if (!_enabled) {
      return;
    }

    _logger.info('[Startup] $message');
  }

  /// Log a startup error with stack trace.
  void error(String message, Object error, StackTrace stackTrace) {
    _logger.error(
      '[Startup][Error] $message',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
