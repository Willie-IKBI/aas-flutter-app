import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';

/// Unified Authentication & User Management Service
/// 
/// Handles all authentication-related operations and user profile management
/// with consistent error handling and type safety.
class AuthService {
  static final SupabaseClient _client = SupabaseConfig.client;
  static final GoTrueClient _auth = SupabaseConfig.auth;

  // ===== AUTHENTICATION OPERATIONS =====

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      // Validate inputs
      if (!_isValidEmail(email)) {
        throw AuthException('Invalid email format');
      }
      
      if (!_isStrongPassword(password)) {
        throw AuthException('Password does not meet security requirements');
      }

      final response = await _auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      
      if (response.user != null) {
        if (kDebugMode) {
          print('✅ User signed up successfully: ${response.user!.id}');
        }
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign up error: $e');
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
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (kDebugMode) {
        print('✅ User signed in successfully: ${response.user?.id}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign in error: $e');
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
      await _auth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTo,
      );
      
      if (kDebugMode) {
        print('✅ Magic link sent to: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Magic link error: $e');
      }
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      
      if (kDebugMode) {
        print('✅ User signed out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign out error: $e');
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
      // Validate email format
      if (!_isValidEmail(email)) {
        throw AuthException('Invalid email format');
      }

      // Use the app's reset password URL if not provided
      final resetUrl = redirectTo ?? 'https://aasupplies-f5711.web.app';
      
      await _auth.resetPasswordForEmail(
        email,
        redirectTo: resetUrl,
      );
      
      if (kDebugMode) {
        print('✅ Password reset email sent to: $email');
        print('📧 Reset URL: $resetUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Password reset error: $e');
      }
      rethrow;
    }
  }



  /// Update password
  static Future<UserResponse> updatePassword({
    required String newPassword,
  }) async {
    try {
      if (!_isStrongPassword(newPassword)) {
        throw AuthException('Password does not meet security requirements');
      }

      final response = await _auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      if (kDebugMode) {
        print('✅ Password updated successfully');
        print('✅ User: ${response.user?.email}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Password update error: $e');
      }
      rethrow;
    }
  }

  /// Check if current session is from password recovery
  static bool get isPasswordRecoverySession {
    try {
      final currentUrl = html.window.location.href;
      return currentUrl.contains('type=recovery') ||
             currentUrl.contains('access_token=') ||
             currentUrl.contains('refresh_token=') ||
             currentUrl.contains('token=') ||
             currentUrl.contains('code=') ||
             currentUrl.contains('reset-password') ||
             currentUrl.contains('recovery');
    } catch (e) {
      return false;
    }
  }

  // ===== USER PROFILE MANAGEMENT =====

  /// Get current user profile (typed)
  static Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _client
          .from('profile')
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting current user profile: $e');
      }
      return null;
    }
  }

  /// Get user profile by ID (typed)
  static Future<UserProfile?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('profile')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user by ID: $e');
      }
      return null;
    }
  }

  /// Update current user profile
  static Future<bool> updateCurrentUserProfile({
    String? displayName,
    String? contactNumber,
    String? department,
    String? location,
    String? empId,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (contactNumber != null) updates['contact_number'] = contactNumber;
      if (department != null) updates['department'] = department;
      if (location != null) updates['location'] = location;
      if (empId != null) updates['emp_id'] = empId;

      await _client
          .from('profile')
          .update(updates)
          .eq('id', user.id);

      if (kDebugMode) {
        print('✅ Current user profile updated successfully');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating current user profile: $e');
      }
      return false;
    }
  }

  // ===== ROLE MANAGEMENT =====

  /// Get all users (admin/manager only)
  static Future<List<UserProfile>> getAllUsers() async {
    try {
      // Check authentication
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get current user's profile to verify role
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile == null) {
        throw Exception('Current user profile not found');
      }

      // Verify admin/manager role
      if (!currentProfile.role.canManageUsers) {
        throw Exception('Insufficient permissions. Admin or Manager role required.');
      }

      if (kDebugMode) {
        print('🔍 Fetching all users from database...');
      }

      final response = await _client
          .from('profile')
          .select()
          .order('created_at', ascending: false);

      final List<UserProfile> users = (response as List)
          .map((userData) => UserProfile.fromJson(userData))
          .toList();
          
      if (kDebugMode) {
        print('✅ Retrieved ${users.length} users');
      }
      
      return users;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in getAllUsers: $e');
      }
      rethrow;
    }
  }

  /// Get unassigned users
  static Future<List<UserProfile>> getUnassignedUsers() async {
    try {
      if (kDebugMode) {
        print('🔍 Fetching unassigned users...');
      }
      
      final response = await _client
          .from('profile')
          .select()
          .eq('role', 'unassigned')
          .order('created_at', ascending: false);

      final users = (response as List)
          .map((user) => UserProfile.fromJson(user))
          .toList();
          
      if (kDebugMode) {
        print('✅ Retrieved ${users.length} unassigned users');
      }
      
      return users;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting unassigned users: $e');
      }
      return [];
    }
  }

  /// Assign role to user (admin/manager only)
  static Future<bool> assignUserRole({
    required String targetUserId,
    required UserRole newRole,
  }) async {
    try {
      if (kDebugMode) {
        print('🔧 Starting role assignment...');
        print('   Target User ID: $targetUserId');
        print('   New Role: ${newRole.name}');
      }
      
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Call the RPC function with proper parameters
      final response = await _client.rpc('assign_user_role', params: {
        'target_user_id': targetUserId,
        'new_role': newRole.toDatabaseString(),
        'assigned_by_user_id': currentUser.id,
      });

      final result = response == true;
      
      if (kDebugMode) {
        print('   Assignment successful: $result');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error assigning user role: $e');
      }
      rethrow;
    }
  }

  // ===== ROLE & PERMISSION CHECKS =====

  /// Get current user role
  static Future<UserRole?> getCurrentUserRole() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.role;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting current user role: $e');
      }
      return null;
    }
  }

  /// Check if current user has specific role
  static Future<bool> hasRole(UserRole role) async {
    final currentRole = await getCurrentUserRole();
    return currentRole == role;
  }

  /// Check if current user is admin
  static Future<bool> get isAdmin async {
    final role = await getCurrentUserRole();
    return role == UserRole.admin;
  }

  /// Check if current user is manager
  static Future<bool> get isManager async {
    final role = await getCurrentUserRole();
    return role == UserRole.manager;
  }

  /// Check if current user is sales representative
  static Future<bool> get isSalesRep async {
    final role = await getCurrentUserRole();
    return role == UserRole.salesRep;
  }

  /// Check if current user is technician
  static Future<bool> get isTechnician async {
    final role = await getCurrentUserRole();
    return role == UserRole.technician;
  }

  /// Check if current user is unassigned
  static Future<bool> get isUnassigned async {
    final role = await getCurrentUserRole();
    return role == UserRole.unassigned;
  }

  /// Check if current user can access dashboard
  static Future<bool> get canAccessDashboard async {
    if (!isAuthenticated) return false;
    
    final profile = await getCurrentUserProfile();
    if (profile == null) return false;
    
    return profile.role.canAccessDashboard && profile.isActive;
  }

  /// Check if current user can assign roles
  static Future<bool> get canAssignRoles async {
    final profile = await getCurrentUserProfile();
    return profile?.role.canAssignRoles ?? false;
  }

  /// Check if current user can manage users
  static Future<bool> get canManageUsers async {
    final profile = await getCurrentUserProfile();
    return profile?.role.canManageUsers ?? false;
  }

  /// Check if current user can manage parts
  static Future<bool> get canManageParts async {
    final profile = await getCurrentUserProfile();
    return profile?.role.canManageParts ?? false;
  }

  /// Check if current user can manage sales
  static Future<bool> get canManageSales async {
    final profile = await getCurrentUserProfile();
    return profile?.role.canManageSales ?? false;
  }

  /// Get all user permissions
  static Future<Map<String, bool>> getUserPermissions() async {
    final profile = await getCurrentUserProfile();
    if (profile == null) {
      return {
        'canAccessDashboard': false,
        'canAssignRoles': false,
        'canManageUsers': false,
        'canManageParts': false,
        'canManageSales': false,
        'isAdmin': false,
        'isManager': false,
        'isSalesRep': false,
        'isTechnician': false,
        'isUnassigned': true,
        'isActive': false,
        'isPending': true,
      };
    }

    return {
      'canAccessDashboard': profile.role.canAccessDashboard && profile.isActive,
      'canAssignRoles': profile.role.canAssignRoles,
      'canManageUsers': profile.role.canManageUsers,
      'canManageParts': profile.role.canManageParts,
      'canManageSales': profile.role.canManageSales,
      'isAdmin': profile.isAdmin,
      'isManager': profile.isManager,
      'isSalesRep': profile.isSalesRep,
      'isTechnician': profile.isTechnician,
      'isUnassigned': profile.isUnassigned,
      'isActive': profile.isActive,
      'isPending': profile.isPending,
    };
  }

  // ===== SESSION MANAGEMENT =====

  /// Get current session
  static Session? get currentSession => _auth.currentSession;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get user ID
  static String? get userId => currentUser?.id;

  /// Get user email
  static String? get userEmail => currentUser?.email;

  /// Get user metadata
  static Map<String, dynamic>? get userMetadata => currentUser?.userMetadata;

  /// Get app metadata
  static Map<String, dynamic>? get appMetadata => currentUser?.appMetadata;

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Listen to user changes
  static Stream<User?> get userChanges => _auth.onAuthStateChange.map((event) => event.session?.user);

  /// Refresh session
  static Future<AuthResponse> refreshSession() async {
    try {
      final response = await _auth.refreshSession();
      
      if (kDebugMode) {
        print('✅ Session refreshed successfully');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Session refresh error: $e');
      }
      rethrow;
    }
  }

  // ===== UTILITY METHODS =====

  /// Get user-friendly error message
  static String getErrorMessage(dynamic error) {
    return SupabaseConfig.handleError(error);
  }

  /// Check if email is valid
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Check if password is strong
  static bool _isStrongPassword(String password) {
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

  /// Get password strength level (0-5)
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
