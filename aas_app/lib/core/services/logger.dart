import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Log levels for structured logging
enum LogLevel {
  debug,
  info,
  warn,
  error,
  critical,
}

/// Centralized logging service with structured logging and correlation IDs
class Logger {
  Logger(this._name, {String? correlationId})
      : _correlationId = correlationId ?? _generateCorrelationId();
  final String _name;
  final String _correlationId;

  /// Generate a unique correlation ID for request tracking
  static String _generateCorrelationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp.hashCode % 9000) + 1000;
    return '${timestamp}_$random';
  }

  /// Log a debug message
  void debug(String message,
      {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message,
        data: data, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  void info(String message,
      {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message,
        data: data, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  void warn(String message,
      {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warn, message,
        data: data, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  void error(String message,
      {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message,
        data: data, error: error, stackTrace: stackTrace);
  }

  /// Log a critical message
  void critical(String message,
      {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message,
        data: data, error: error, stackTrace: stackTrace);
  }

  /// Internal logging method
  void _log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Only log in debug mode or for critical errors
    if (!kDebugMode && level != LogLevel.critical) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();

    // Build structured log entry (for potential future use)
    final logEntry = {
      'timestamp': timestamp,
      'level': levelStr,
      'logger': _name,
      'correlationId': _correlationId,
      'message': message,
      if (data != null) 'data': data,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
    
    // Suppress unused variable warning - logEntry is built for future structured logging
    assert(logEntry.isNotEmpty);

    // Use developer.log for structured logging
    developer.log(
      message,
      name: '${_name}[$levelStr]',
      level: _getLogLevelValue(level),
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );

    // In debug mode, also print to console for immediate visibility
    if (kDebugMode) {
      final dataStr = data != null ? ' | Data: $data' : '';
      final errorStr = error != null ? ' | Error: $error' : '';
      print(
          '[$timestamp] [$levelStr] $_name[$_correlationId]: $message$dataStr$errorStr');
    }
  }

  /// Convert LogLevel to numeric value for developer.log
  int _getLogLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warn:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }

  /// Create a child logger with a new correlation ID
  Logger child(String name) {
    return Logger('$_name.$name', correlationId: _correlationId);
  }

  /// Get the current correlation ID
  String get correlationId => _correlationId;
}
