import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'secure_config.dart';

/// Supabase Configuration
///
/// This file contains the configuration for Supabase integration.
/// Uses SecureConfig for secure key management.
class SupabaseConfig {
  // Private constructor to prevent instantiation
  SupabaseConfig._();

  // ===== SUPABASE CREDENTIALS =====

  /// Supabase URL - Retrieved securely
  static String get supabaseUrl => SecureConfig.supabaseUrl;

  /// Supabase Anon Key - Retrieved securely
  static String get supabaseAnonKey => SecureConfig.supabaseAnonKey;

  // ===== STORAGE BUCKETS =====

  /// Order files bucket name
  static const String orderFilesBucket = 'order-files';

  /// Profile images bucket name
  static const String profileImagesBucket = 'profile-images';

  /// Part images bucket name
  static const String partImagesBucket = 'AAS';

  // ===== DATABASE TABLES =====

  /// Database table names
  static const String profilesTable = 'profile';
  static const String customersTable = 'customers';
  static const String ordersTable = 'orders';
  static const String orderStageEventsTable = 'order_stage_events';
  static const String orderDocumentsTable = 'order_documents';
  static const String partsInventoryTable = 'parts_inventory';
  static const String orderPartsTable = 'order_parts';
  static const String resourceAllocationsTable = 'resource_allocations';
  static const String approvalsTable = 'approvals';

  // ===== INITIALIZATION =====

  /// Initialize Supabase
  static Future<void> initialize() async {
    try {
      // Initialize secure configuration first
      await SecureConfig.initialize();

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
        storageOptions: const StorageClientOptions(
          retryAttempts: 3,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );

      if (kDebugMode) {}
    } catch (error) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  // ===== CLIENT ACCESS =====

  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get auth client
  static GoTrueClient get auth => client.auth;

  /// Get database client
  static PostgrestClient get database => client.rest;

  /// Get storage client
  static dynamic get storage => client.storage;

  /// Get realtime client
  static RealtimeClient get realtime => client.realtime;

  // ===== UTILITY METHODS =====

  /// Check if Supabase is initialized
  static bool get isInitialized => Supabase.instance.client != null;

  /// Get current user
  static User? get currentUser => auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get user ID
  static String? get userId => currentUser?.id;

  /// Get user email
  static String? get userEmail => currentUser?.email;

  // ===== ERROR HANDLING =====

  /// Handle Supabase errors
  static String handleError(dynamic error) {
    if (error is AuthException) {
      return _handleAuthError(error);
    } else if (error is PostgrestException) {
      return _handleDatabaseError(error);
    } else if (error is StorageException) {
      return _handleStorageError(error);
    } else {
      return error.toString();
    }
  }

  /// Handle authentication errors
  static String _handleAuthError(AuthException error) {
    switch (error.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password';
      case 'Email not confirmed':
        return 'Please verify your email address';
      case 'User already registered':
        return 'An account with this email already exists';
      case 'Password should be at least 6 characters':
        return 'Password must be at least 6 characters long';
      default:
        return error.message;
    }
  }

  /// Handle database errors
  static String _handleDatabaseError(PostgrestException error) {
    switch (error.code) {
      case 'PGRST116':
        return 'Record not found';
      case 'PGRST301':
        return 'Access denied';
      case 'PGRST302':
        return 'Invalid request';
      default:
        return error.message;
    }
  }

  /// Handle storage errors
  static String _handleStorageError(StorageException error) {
    switch (error.statusCode) {
      case 404:
        return 'File not found';
      case 403:
        return 'Access denied to file';
      case 413:
        return 'File too large';
      default:
        return error.message;
    }
  }
}
