import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'error_service.dart';
import 'logger.dart';

/// Centralized user feedback service for consistent UX
class UserFeedbackService {
  static final Logger _logger = Logger('UserFeedbackService');

  /// Show error feedback to user
  static void showError(
    BuildContext context,
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
    VoidCallback? onRetry,
    String? retryLabel,
  }) {
    final errorResult =
        ErrorService.mapError(error, context: context, stackTrace: stackTrace);

    _logger.warn(
      'Showing error to user',
      data: {
        'errorCode': errorResult.errorCode,
        'correlationId': errorResult.correlationId,
        'isRetryable': errorResult.isRetryable,
      },
    );

    if (errorResult.isRetryable && onRetry != null) {
      _showRetryableErrorSnackbar(
        context,
        errorResult.userMessage,
        onRetry: onRetry,
        retryLabel: retryLabel ?? 'Retry',
      );
    } else {
      _showErrorSnackbar(context, errorResult.userMessage);
    }
  }

  /// Show success feedback to user
  static void showSuccess(BuildContext context, String message) {
    _logger.info('Showing success message to user', data: {'message': message});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show warning feedback to user
  static void showWarning(BuildContext context, String message) {
    _logger.warn('Showing warning message to user', data: {'message': message});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show info feedback to user
  static void showInfo(BuildContext context, String message) {
    _logger.info('Showing info message to user', data: {'message': message});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show blocking error dialog for critical failures
  static void showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    String? context,
    StackTrace? stackTrace,
    VoidCallback? onRetry,
    String? retryLabel,
  }) {
    final errorResult =
        ErrorService.mapError(error, context: context, stackTrace: stackTrace);

    _logger.error(
      'Showing error dialog to user',
      data: {
        'errorCode': errorResult.errorCode,
        'correlationId': errorResult.correlationId,
      },
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title ?? 'Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorResult.userMessage),
            const SizedBox(height: 16),
            Text(
              'Error ID: ${errorResult.correlationId}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        actions: [
          if (errorResult.isRetryable && onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(retryLabel ?? 'Retry'),
            ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show retryable error snackbar with retry action
  static void _showRetryableErrorSnackbar(
    BuildContext context,
    String message, {
    required VoidCallback onRetry,
    required String retryLabel,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: retryLabel,
          textColor: Colors.white,
          onPressed: onRetry,
        ),
      ),
    );
  }

  /// Show simple error snackbar
  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Clear all snackbars
  static void clearSnackbars(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}

/// Provider for UserFeedbackService
final userFeedbackProvider = Provider<UserFeedbackService>((ref) {
  return UserFeedbackService();
});
