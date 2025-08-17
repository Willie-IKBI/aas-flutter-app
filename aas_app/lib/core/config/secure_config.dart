import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

/// Secure Configuration Management
/// 
/// This file provides secure ways to handle API keys and sensitive configuration
/// based on the environment (development, staging, production).
class SecureConfig {
  SecureConfig._();

  // ===== ENVIRONMENT DETECTION =====
  
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => !kDebugMode;
  static bool get isTest => Platform.environment.containsKey('FLUTTER_TEST');

  // ===== SECURE KEY RETRIEVAL =====

  /// Get Supabase URL with validation
  static String get supabaseUrl {
    final url = _getSupabaseUrl();
    _validateUrl(url);
    return url;
  }

  /// Get Supabase Anon Key with validation
  static String get supabaseAnonKey {
    final key = _getSupabaseAnonKey();
    _validateAnonKey(key);
    return key;
  }

  // ===== PRIVATE KEY RETRIEVAL METHODS =====

  static String _getSupabaseUrl() {
    // Priority order for URL retrieval:
    // 1. Build-time environment variables (most secure for production)
    // 2. .env file (for development)
    // 3. Fallback values
    
    // Check build-time environment variables first
    const buildTimeUrl = String.fromEnvironment('SUPABASE_URL');
    if (buildTimeUrl.isNotEmpty && buildTimeUrl != 'SUPABASE_URL') {
      return buildTimeUrl;
    }

    // Check .env file (development only)
    if (isDevelopment && !kIsWeb) {
      try {
        final envUrl = dotenv.env['SUPABASE_URL'];
        if (envUrl != null && envUrl.isNotEmpty) {
          return envUrl;
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Could not load .env file: $e');
        }
      }
    }

    // Fallback for development
    if (isDevelopment) {
      return 'https://adryhxoeywqkeufnzepe.supabase.co';
    }

    throw Exception('SUPABASE_URL not configured for production');
  }

  static String _getSupabaseAnonKey() {
    // Priority order for key retrieval:
    // 1. Build-time environment variables (most secure for production)
    // 2. .env file (for development)
    // 3. Fallback values
    
    // Check build-time environment variables first
    const buildTimeKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (buildTimeKey.isNotEmpty && buildTimeKey != 'SUPABASE_ANON_KEY') {
      return buildTimeKey;
    }

    // Check .env file (development only)
    if (isDevelopment && !kIsWeb) {
      try {
        final envKey = dotenv.env['SUPABASE_ANON_KEY'];
        if (envKey != null && envKey.isNotEmpty) {
          return envKey;
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Could not load .env file: $e');
        }
      }
    }

    // Fallback for development
    if (isDevelopment) {
      return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFkcnloeG9leXdxa2V1Zm56ZXBlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY3NDg0ODYsImV4cCI6MjA0MjMyNDQ4Nn0.NEZ8FIMqDCpNPDS8xszwwGId2LcMgoEwkkpg_mxixqM';
    }

    throw Exception('SUPABASE_ANON_KEY not configured for production');
  }

  // ===== VALIDATION METHODS =====

  static void _validateUrl(String url) {
    if (url.isEmpty) {
      throw Exception('SUPABASE_URL cannot be empty');
    }
    
    if (!url.startsWith('https://')) {
      throw Exception('SUPABASE_URL must use HTTPS');
    }
    
    if (!url.contains('.supabase.co')) {
      throw Exception('SUPABASE_URL must be a valid Supabase URL');
    }
  }

  static void _validateAnonKey(String key) {
    if (key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY cannot be empty');
    }
    
    if (!key.startsWith('eyJ')) {
      throw Exception('SUPABASE_ANON_KEY must be a valid JWT token');
    }
  }

  // ===== INITIALIZATION =====

  /// Initialize secure configuration
  static Future<void> initialize() async {
    if (isDevelopment) {
      try {
        // For web, we need to handle .env differently
        if (kIsWeb) {
          if (kDebugMode) {
            print('🌐 Web environment detected - using fallback configuration');
          }
        } else {
          await dotenv.load(fileName: '.env');
          if (kDebugMode) {
            print('✅ Environment variables loaded from .env');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Could not load .env file: $e');
        }
      }
    }

    // Validate configuration
    _validateUrl(_getSupabaseUrl());
    _validateAnonKey(_getSupabaseAnonKey());

    if (kDebugMode) {
      print('✅ Secure configuration validated');
      print('🌍 Environment: ${isDevelopment ? 'Development' : 'Production'}');
    }
  }

  // ===== SECURITY UTILITIES =====

  /// Check if keys are properly configured
  static bool get isConfigured {
    try {
      _validateUrl(_getSupabaseUrl());
      _validateAnonKey(_getSupabaseAnonKey());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get configuration status for debugging
  static Map<String, dynamic> get configurationStatus {
    bool envFileLoaded = false;
    if (isDevelopment && !kIsWeb) {
      try {
        envFileLoaded = dotenv.env.isNotEmpty;
      } catch (e) {
        envFileLoaded = false;
      }
    }
    
    return {
      'environment': isDevelopment ? 'development' : 'production',
      'isConfigured': isConfigured,
      'urlConfigured': _getSupabaseUrl().isNotEmpty,
      'keyConfigured': _getSupabaseAnonKey().isNotEmpty,
      'envFileLoaded': envFileLoaded,
    };
  }
}
