import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';
import 'logger.dart';

/// Unified Authentication & User Management Service
///
/// Handles all authentication-related operations and user profile management
/// with consistent error handling and type safety.
class AuthService {
  static final SupabaseClient _client = SupabaseConfig.client;
  static final GoTrueClient _auth = SupabaseConfig.auth;
  static final Logger _logger = Logger('AuthService');

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
        throw const AuthException('Invalid email format');
      }

      if (!_isStrongPassword(password)) {
        throw const AuthException(
            'Password does not meet security requirements');
      }

      final response = await _auth.signUp(
        email: email,
        password: password,
        data: userData,
      );

      if (response.user != null) {
        _logger.info('User signed up successfully', data: {'email': email});
      }

      return response;
    } catch (e) {
      _logger.error('Sign up failed', error: e, data: {'email': email});
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

      _logger.info('User signed in successfully', data: {'email': email});

      return response;
    } catch (e) {
      _logger.error('Sign in failed', error: e, data: {'email': email});
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
        print('Magic link sent to $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Magic link sign in failed: $e');
      }
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();

      if (kDebugMode) {
        print('User signed out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sign out failed: $e');
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
        throw const AuthException('Invalid email format');
      }

      // Use the app's reset password URL if not provided
      final resetUrl = redirectTo ?? 'https://aasupplies-f5711.web.app';

      await _auth.resetPasswordForEmail(
        email,
        redirectTo: resetUrl,
      );

      if (kDebugMode) {
        print('Password reset email sent to $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Password reset failed: $e');
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
        throw const AuthException(
            'Password does not meet security requirements');
      }

      final response = await _auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (kDebugMode) {
        print('Password updated successfully');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Password update failed: $e');
      }
      rethrow;
    }
  }

  // Note: Password recovery detection is now handled by the router
  // This method is deprecated and will be removed in future versions

  // ===== USER PROFILE MANAGEMENT =====

  /// Get current user profile (typed)
  static Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response =
          await _client.from('profile').select().eq('id', user.id).single();

      return UserProfile.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get current user profile: $e');
      }
      return null;
    }
  }

  /// Get user profile by ID (typed)
  static Future<UserProfile?> getUserById(String userId) async {
    try {
      final response =
          await _client.from('profile').select().eq('id', userId).single();

      return UserProfile.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get user profile by ID: $e');
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

      await _client.from('profile').update(updates).eq('id', user.id);

      if (kDebugMode) {
        print('User profile updated successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user profile: $e');
      }
      return false;
    }
  }

  /// Update any user's profile (admin/manager only)
  static Future<bool> updateUserProfile({
    required String targetUserId,
    String? displayName,
    String? contactNumber,
    String? department,
    String? location,
    String? empId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (kDebugMode) {
        print('Updating user profile for user: $targetUserId');
      }

      // Validate display name if provided
      if (displayName != null && !_isValidDisplayName(displayName)) {
        throw Exception('Display name must be between 2 and 50 characters');
      }

      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (contactNumber != null) updates['contact_number'] = contactNumber;
      if (department != null) updates['department'] = department;
      if (location != null) updates['location'] = location;
      if (empId != null) updates['emp_id'] = empId;

      if (kDebugMode) {
        print('Updating profile with data: $updates');
      }

      await _client
          .from('profile')
          .update(updates)
          .eq('id', targetUserId)
          .select();

      if (kDebugMode) {
        print('User profile updated successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        if (e.toString().contains('RLS')) {
          print('RLS policy issue: $e');
        } else {
          print('Failed to update user profile: $e');
        }
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
        throw Exception(
            'Insufficient permissions. Admin or Manager role required.');
      }

      if (kDebugMode) {
        print('Getting all users for admin/manager');
      }

      final response = await _client
          .from('profile')
          .select()
          .order('created_at', ascending: false);

      final users = (response as List)
          .map((userData) => UserProfile.fromJson(userData))
          .toList();

      if (kDebugMode) {
        print('Retrieved ${users.length} users');
      }

      return users;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get all users: $e');
      }
      rethrow;
    }
  }

  /// Get unassigned users
  static Future<List<UserProfile>> getUnassignedUsers() async {
    try {
      if (kDebugMode) {
        print('Debug message');
      }

      final response = await _client
          .from('profile')
          .select()
          .eq('role', 'unassigned')
          .order('created_at', ascending: false);

      final users =
          (response as List).map((user) => UserProfile.fromJson(user)).toList();

      if (kDebugMode) {
        print('Debug message');
      }

      return users;
    } catch (e) {
      if (kDebugMode) {
        print('Debug message');
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
        print('Debug message');
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Call the RPC function with proper parameters
      final response = await _client.rpc<bool>('assign_user_role', params: {
        'target_user_id': targetUserId,
        'new_role': newRole.toDatabaseString(),
        'assigned_by_user_id': currentUser.id,
      });

      final result = response == true;

      if (kDebugMode) {
        print('Debug message');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Debug message');
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
        print('Debug message');
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
  static Stream<User?> get userChanges =>
      _auth.onAuthStateChange.map((event) => event.session?.user);

  /// Refresh session
  static Future<AuthResponse> refreshSession() async {
    try {
      final response = await _auth.refreshSession();

      if (kDebugMode) {
        print('Debug message');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Debug message');
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
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);
  }

  /// Check if display name is valid
  static bool _isValidDisplayName(String displayName) {
    final trimmed = displayName.trim();
    return trimmed.length >= 2 && trimmed.length <= 50;
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
    var level = 0;
    if (password.length >= 8) level++;
    if (RegExp(r'[A-Z]').hasMatch(password)) level++;
    if (RegExp(r'[a-z]').hasMatch(password)) level++;
    if (RegExp(r'\d').hasMatch(password)) level++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) level++;
    return level;
  }
}
