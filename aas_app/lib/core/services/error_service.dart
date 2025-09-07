import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'logger.dart';

/// Result of error mapping with user-safe message and metadata
class ErrorResult {
  const ErrorResult({
    required this.userMessage,
    required this.errorCode,
    required this.correlationId,
    required this.isRetryable,
  });
  final String userMessage;
  final String errorCode;
  final String correlationId;
  final bool isRetryable;
}

/// Centralized error handling service for all error sources
class ErrorService {
  static final Logger _logger = Logger('ErrorService');

  /// Maps any error to user-friendly messages with stable error codes
  static ErrorResult mapError(dynamic error,
      {String? context, StackTrace? stackTrace}) {
    final correlationId = _generateCorrelationId();

    // Log the error with full details
    _logger.error(
      'Error occurred${context != null ? ' in $context' : ''}',
      data: {
        'errorType': error.runtimeType.toString(),
        'correlationId': correlationId,
      },
      error: error,
      stackTrace: stackTrace,
    );

    // Map to user-safe message
    final userMessage = _mapToUserMessage(error);
    final errorCode = _getErrorCode(error);

    return ErrorResult(
      userMessage: userMessage,
      errorCode: errorCode,
      correlationId: correlationId,
      isRetryable: _isRetryable(error),
    );
  }

  /// Legacy method for backward compatibility
  static String mapSupabaseError(dynamic error) {
    return mapError(error).userMessage;
  }

  /// Generate a unique correlation ID
  static String _generateCorrelationId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + (DateTime.now().microsecond % 9000)).toString();
  }

  /// Map any error to user-safe message
  static String _mapToUserMessage(dynamic error) {
    if (error is AuthException) {
      return _mapAuthError(error);
    } else if (error is PostgrestException) {
      return _mapPostgrestError(error);
    } else if (error is StorageException) {
      return _mapStorageError(error);
    } else if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is HttpException) {
      return _mapHttpError(error);
    } else if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    } else if (error is StateError) {
      return 'Application state error. Please refresh and try again.';
    } else if (error is ArgumentError) {
      return 'Invalid input. Please check your data and try again.';
    } else if (error is Exception) {
      return _mapGenericError(error);
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Get stable error code for error tracking
  static String _getErrorCode(dynamic error) {
    if (error is AuthException) {
      return 'AUTH_${error.statusCode ?? 'UNKNOWN'}';
    } else if (error is PostgrestException) {
      return 'DB_${error.code ?? 'UNKNOWN'}';
    } else if (error is StorageException) {
      return 'STORAGE_${error.statusCode ?? 'UNKNOWN'}';
    } else if (error is SocketException) {
      return 'NETWORK_OFFLINE';
    } else if (error is TimeoutException) {
      return 'NETWORK_TIMEOUT';
    } else if (error is HttpException) {
      return 'HTTP_${error.message}';
    } else if (error is FormatException) {
      return 'FORMAT_ERROR';
    } else if (error is StateError) {
      return 'STATE_ERROR';
    } else if (error is ArgumentError) {
      return 'ARGUMENT_ERROR';
    }

    return 'UNKNOWN_ERROR';
  }

  /// Check if error is retryable
  static bool _isRetryable(dynamic error) {
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is HttpException) {
      final message = error.message.toLowerCase();
      return message.contains('500') ||
          message.contains('502') ||
          message.contains('503');
    }
    if (error is PostgrestException) {
      return error.code == 'PGRST301'; // Permission error might be retryable
    }
    return false;
  }

  /// Map HTTP errors to user-friendly messages
  static String _mapHttpError(HttpException error) {
    final message = error.message.toLowerCase();
    if (message.contains('401')) {
      return 'Authentication required. Please sign in again.';
    } else if (message.contains('403')) {
      return 'You do not have permission to perform this action.';
    } else if (message.contains('404')) {
      return 'The requested resource was not found.';
    } else if (message.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (message.contains('502') || message.contains('503')) {
      return 'Service temporarily unavailable. Please try again.';
    }
    return 'Network error. Please try again.';
  }

  /// Maps authentication errors to user-friendly messages
  static String _mapAuthError(AuthException error) {
    switch (error.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password. Please check your credentials.';
      case 'Email not confirmed':
        return 'Please check your email and confirm your account.';
      case 'User not found':
        return 'No account found with this email address.';
      case 'Password should be at least 6 characters':
        return 'Password must be at least 6 characters long.';
      case 'Signup is disabled':
        return 'Account registration is currently disabled.';
      case 'Email rate limit exceeded':
        return 'Too many email requests. Please wait before trying again.';
      default:
        return 'Authentication error. Please try again.';
    }
  }

  /// Maps database errors to user-friendly messages
  static String _mapPostgrestError(PostgrestException error) {
    switch (error.code) {
      case 'PGRST204':
        return 'The requested data was not found.';
      case 'PGRST301':
        return 'You do not have permission to access this data.';
      case '23505': // Unique constraint violation
        return 'This record already exists.';
      case '23503': // Foreign key constraint violation
        return 'Cannot delete this record as it is referenced by other data.';
      case '23502': // Not null constraint violation
        return 'Required information is missing.';
      default:
        return 'Database error. Please try again.';
    }
  }

  /// Maps storage errors to user-friendly messages
  static String _mapStorageError(StorageException error) {
    switch (error.statusCode) {
      case '404':
        return 'File not found.';
      case '403':
        return 'You do not have permission to access this file.';
      case '413':
        return 'File is too large. Please choose a smaller file.';
      case '415':
        return 'File type not supported.';
      default:
        return 'File operation failed. Please try again.';
    }
  }

  /// Maps generic errors to user-friendly messages
  static String _mapGenericError(Exception error) {
    final message = error.toString().toLowerCase();

    if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    } else if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (message.contains('permission') ||
        message.contains('unauthorized')) {
      return 'You do not have permission to perform this action.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Logs technical error details for debugging (legacy method)
  static void logError(dynamic error, StackTrace? stackTrace,
      {String? context}) {
    _logger.error(
      'Error occurred${context != null ? ' in $context' : ''}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
