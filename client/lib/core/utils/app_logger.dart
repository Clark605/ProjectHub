import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// Structured logging service for ProjectHub.
///
/// Features:
/// - Log levels: debug, info, warning, error
/// - Categorized tags (e.g. `AppLaunch`, `Auth`, `Network`, `Storage`)
/// - Execution timer helper for measuring startup benchmarks
/// - Integrates with both Dart Developer log and formatted console output
class AppLogger {
  AppLogger._();

  static const String _reset = '\x1B[0m';
  static const String _gray = '\x1B[90m';
  static const String _cyan = '\x1B[36m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';

  static void debug(String message, {String tag = 'App'}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  static void info(String message, {String tag = 'App'}) {
    _log(LogLevel.info, message, tag: tag);
  }

  static void warning(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Starts a performance stopwatch and returns an [ExecutionTimer] to measure duration.
  static ExecutionTimer startTimer(
    String operation, {
    String tag = 'Benchmark',
  }) {
    return ExecutionTimer._(operation, tag)..start();
  }

  static void _log(
    LogLevel level,
    String message, {
    required String tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode && level == LogLevel.debug) return;

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';

    final (levelIcon, color) = switch (level) {
      LogLevel.debug => ('🐛 [DEBUG]', _gray),
      LogLevel.info => ('ℹ️ [INFO]', _cyan),
      LogLevel.warning => ('⚠️ [WARN]', _yellow),
      LogLevel.error => ('❌ [ERROR]', _red),
    };

    final formatted = '$color$timeStr $levelIcon [$tag] $message$_reset';

    developer.log(
      message,
      name: tag,
      time: now,
      level: switch (level) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warning => 900,
        LogLevel.error => 1000,
      },
      error: error,
      stackTrace: stackTrace,
    );

    debugPrint(formatted);
    if (error != null) debugPrint('$color$error$_reset');
    if (stackTrace != null) debugPrint('$color$stackTrace$_reset');
  }
}

/// Helper class to benchmark asynchronous or multi-step operations.
class ExecutionTimer {
  final String _operation;
  final String _tag;
  final Stopwatch _stopwatch = Stopwatch();

  ExecutionTimer._(this._operation, this._tag);

  void start() {
    _stopwatch.start();
    AppLogger.debug('⏱️ Started: $_operation', tag: _tag);
  }

  int stop({String? note}) {
    _stopwatch.stop();
    final elapsedMs = _stopwatch.elapsedMilliseconds;
    final extra = note != null ? ' ($note)' : '';
    AppLogger.info(
      '⏱️ Completed: $_operation in ${elapsedMs}ms$extra',
      tag: _tag,
    );
    return elapsedMs;
  }
}
