import 'package:talker/talker.dart';

class AppLogger {
  AppLogger({Talker? talker, String? prefix, bool enabled = true})
    : _talker = talker ?? Talker(),
      _prefix = prefix,
      _enabled = enabled;

  final Talker _talker;
  final String? _prefix;
  final bool _enabled;

  Talker get talker => _talker;

  void debug(String message) {
    if (!_enabled) {
      return;
    }

    _talker.debug(_withPrefix(message));
  }

  void info(String message) {
    if (!_enabled) {
      return;
    }

    _talker.info(_withPrefix(message));
  }

  void warning(String message) {
    if (!_enabled) {
      return;
    }

    _talker.warning(_withPrefix(message));
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (!_enabled) {
      return;
    }

    _talker.error(_withPrefix(message), error, stackTrace);
  }

  void critical(String message, {Object? error, StackTrace? stackTrace}) {
    if (!_enabled) {
      return;
    }

    _talker.critical(_withPrefix(message), error, stackTrace);
  }

  String _withPrefix(String message) {
    if (_prefix == null || _prefix.isEmpty) {
      return message;
    }

    return '$_prefix $message';
  }
}
