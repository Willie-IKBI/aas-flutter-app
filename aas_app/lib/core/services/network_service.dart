import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'logger.dart';

/// Network connectivity and offline detection service
class NetworkService {
  static final Logger _logger = Logger('NetworkService');
  static final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  /// Stream of connectivity status changes
  static Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  static bool _isConnected = true;
  static bool get isConnected => _isConnected;

  /// Check if device is currently online
  static Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      if (connected != _isConnected) {
        _isConnected = connected;
        _connectivityController.add(_isConnected);

        _logger.info(
          'Connectivity status changed',
          data: {'isConnected': _isConnected},
        );
      }

      return connected;
    } catch (e) {
      if (_isConnected) {
        _isConnected = false;
        _connectivityController.add(_isConnected);

        _logger.warn(
          'Connectivity check failed',
          error: e,
          data: {'isConnected': _isConnected},
        );
      }
      return false;
    }
  }

  /// Check if a specific host is reachable
  static Future<bool> checkHostReachability(String host) async {
    try {
      final result = await InternetAddress.lookup(host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _logger.warn(
        'Host reachability check failed',
        error: e,
        data: {'host': host},
      );
      return false;
    }
  }

  /// Check Supabase connectivity specifically
  static Future<bool> checkSupabaseConnectivity() async {
    // Check if we can reach Supabase's health endpoint
    return await checkHostReachability('supabase.com');
  }

  /// Initialize network monitoring
  static void initialize() {
    _logger.info('Initializing network service');

    // Check initial connectivity
    checkConnectivity();

    // Set up periodic connectivity checks
    Timer.periodic(const Duration(seconds: 30), (timer) {
      checkConnectivity();
    });
  }

  /// Dispose of resources
  static void dispose() {
    _connectivityController.close();
  }

  /// Get user-friendly offline message
  static String getOfflineMessage() {
    return 'No internet connection. Please check your network and try again.';
  }

  /// Get user-friendly timeout message
  static String getTimeoutMessage() {
    return 'Request timed out. Please check your connection and try again.';
  }

  /// Get user-friendly server error message
  static String getServerErrorMessage() {
    return 'Server error. Please try again later.';
  }
}
