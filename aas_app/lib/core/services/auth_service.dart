import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Authentication Service
/// 
/// Handles all authentication-related operations with Supabase.
class AuthService {
  // Private constructor to prevent instantiation
  AuthService._();

  // ===== AUTHENTICATION METHODS =====

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );

      if (kDebugMode) {
        print('✅ User signed up successfully: ${response.user?.email}');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Sign up failed: $error');
      }
      rethrow;
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ User signed in successfully: ${response.user?.email}');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Sign in failed: $error');
      }
      rethrow;
    }
  }

  /// Sign in with magic link
  static Future<void> signInWithMagicLink({
    required String email,
    String? redirectTo,
  }) async {
    try {
      await SupabaseConfig.auth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTo,
      );

      if (kDebugMode) {
        print('✅ Magic link sent to: $email');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Magic link failed: $error');
      }
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await SupabaseConfig.auth.signOut();

      if (kDebugMode) {
        print('✅ User signed out successfully');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Sign out failed: $error');
      }
      rethrow;
    }
  }

  /// Reset password
  static Future<void> resetPassword({
    required String email,
    String? redirectTo,
  }) async {
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );

      if (kDebugMode) {
        print('✅ Password reset email sent to: $email');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Password reset failed: $error');
      }
      rethrow;
    }
  }

  /// Update password
  static Future<UserResponse> updatePassword({
    required String newPassword,
  }) async {
    try {
      final response = await SupabaseConfig.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (kDebugMode) {
        print('✅ Password updated successfully');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Password update failed: $error');
      }
      rethrow;
    }
  }

  /// Update user profile
  static Future<UserResponse> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await SupabaseConfig.auth.updateUser(
        UserAttributes(data: data),
      );

      if (kDebugMode) {
        print('✅ Profile updated successfully');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Profile update failed: $error');
      }
      rethrow;
    }
  }

  /// Get current session
  static Session? get currentSession => SupabaseConfig.auth.currentSession;

  /// Get current user
  static User? get currentUser => SupabaseConfig.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => SupabaseConfig.isAuthenticated;

  /// Get user ID
  static String? get userId => SupabaseConfig.userId;

  /// Get user email
  static String? get userEmail => SupabaseConfig.userEmail;

  // ===== SESSION MANAGEMENT =====

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges => 
      SupabaseConfig.auth.onAuthStateChange;

  /// Listen to user changes
  static Stream<User?> get userChanges => SupabaseConfig.auth.onAuthStateChange.map((event) => event.session?.user);

  /// Refresh session
  static Future<AuthResponse> refreshSession() async {
    try {
      final response = await SupabaseConfig.auth.refreshSession();

      if (kDebugMode) {
        print('✅ Session refreshed successfully');
      }

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Session refresh failed: $error');
      }
      rethrow;
    }
  }

  // ===== USER MANAGEMENT =====

  /// Get user metadata
  static Map<String, dynamic>? get userMetadata => 
      currentUser?.userMetadata;

  /// Get app metadata
  static Map<String, dynamic>? get appMetadata => 
      currentUser?.appMetadata;

  /// Get user role from metadata
  static String? get userRole {
    final metadata = userMetadata;
    return metadata?['role'] as String?;
  }

  /// Check if user has specific role
  static bool hasRole(String role) {
    return userRole == role;
  }

  /// Check if user is admin
  static bool get isAdmin => hasRole('admin');

  /// Check if user is manager
  static bool get isManager => hasRole('manager') || isAdmin;

  /// Check if user is sales
  static bool get isSales => hasRole('sales') || isManager;

  /// Check if user is technician
  static bool get isTechnician => hasRole('technician');

  // ===== ERROR HANDLING =====

  /// Get user-friendly error message
  static String getErrorMessage(dynamic error) {
    return SupabaseConfig.handleError(error);
  }

  // ===== UTILITY METHODS =====

  /// Check if email is valid
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Check if password is strong
  static bool isStrongPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$')
        .hasMatch(password);
  }

  /// Get password strength message
  static String getPasswordStrengthMessage(String password) {
    if (password.isEmpty) return '';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    return 'Strong password';
  }

  /// Get password strength level (0-4)
  static int getPasswordStrengthLevel(String password) {
    int level = 0;
    if (password.length >= 8) level++;
    if (RegExp(r'[A-Z]').hasMatch(password)) level++;
    if (RegExp(r'[a-z]').hasMatch(password)) level++;
    if (RegExp(r'\d').hasMatch(password)) level++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) level++;
    return level;
  }
}
