import 'dart:html' as html;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';

// ===== AUTH STATE MANAGEMENT =====

/// Auth state notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial()) {
    print('🔍 AuthNotifier - Initializing...');
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    print('🔍 AuthNotifier - Setting up auth listener...');
    // Check current auth state first
    _checkInitialAuthState();
    
    // Then listen for changes
    AuthService.authStateChanges.listen((authState) {
      print('🔍 AuthNotifier - Auth state change detected: ${authState.event}');
      if (authState.event == AuthChangeEvent.signedIn) {
        print('🔍 AuthNotifier - User signed in, loading profile...');
        _loadUserProfile();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        print('🔍 AuthNotifier - User signed out');
        state = const AuthState.unauthenticated();
      } else if (authState.event == AuthChangeEvent.passwordRecovery) {
        print('🔍 AuthNotifier - Password recovery detected - setting password reset state');
        state = const AuthState.passwordReset();
      } else if (authState.event == AuthChangeEvent.initialSession) {
        print('🔍 AuthNotifier - Initial session detected');
        // Check if this initial session is from a password recovery
        _checkForPasswordRecoverySession();
      } else if (authState.event == AuthChangeEvent.userUpdated) {
        print('🔍 AuthNotifier - User updated (password changed)');
        // After password update, check if user has a profile
        _loadUserProfile();
      }
    });
  }

  Future<void> _checkInitialAuthState() async {
    print('🔍 AuthNotifier - Checking initial auth state...');
    
    // First check if this is a password recovery session
    if (AuthService.isPasswordRecoverySession) {
      print('🔍 AuthNotifier - Password recovery detected in initial auth state check');
      state = const AuthState.passwordReset();
      return;
    }
    
    // Check if user is already signed in
    if (AuthService.isAuthenticated) {
      print('🔍 AuthNotifier - User is already authenticated, loading profile...');
      await _loadUserProfile();
    } else {
      print('🔍 AuthNotifier - User is not authenticated');
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> _loadUserProfile() async {
    print('🔍 AuthNotifier - Loading user profile...');
    state = const AuthState.loading();
    
    try {
      final profile = await AuthService.getCurrentUserProfile();
      print('🔍 AuthNotifier - Profile loaded: ${profile?.displayName} (${profile?.role})');
      
      if (profile != null) {
        if (profile.isUnassigned) {
          print('🔍 AuthNotifier - User is unassigned, showing pending approval');
          state = AuthState.pendingApproval(profile);
        } else {
          print('🔍 AuthNotifier - User is authenticated, showing dashboard');
          state = AuthState.authenticated(profile);
        }
      } else {
        // Check if this might be a password recovery scenario
        if (AuthService.isPasswordRecoverySession) {
          print('🔍 AuthNotifier - No profile but recovery params found, showing password reset');
          state = const AuthState.passwordReset();
        } else {
          print('🔍 AuthNotifier - No profile found, showing sign in');
          state = const AuthState.unauthenticated();
        }
      }
    } catch (e) {
      print('🔍 AuthNotifier - Error loading profile: $e');
      state = AuthState.error(e.toString());
    }
  }

  Future<void> refreshUserProfile() async {
    print('🔍 AuthNotifier - Refreshing user profile...');
    await _loadUserProfile();
  }

  Future<void> signOut() async {
    try {
      await AuthService.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void setPasswordResetState() {
    print('🔍 AuthNotifier - Setting password reset state');
    state = const AuthState.passwordReset();
  }

  void _checkForPasswordRecoverySession() {
    // Check if the current URL contains password recovery parameters
    if (AuthService.isPasswordRecoverySession) {
      print('🔍 AuthNotifier - Password recovery session detected in initial session');
      state = const AuthState.passwordReset();
    } else {
      print('🔍 AuthNotifier - Normal initial session, loading profile...');
      _loadUserProfile();
    }
  }
}

/// Auth state representing different authentication states
class AuthState {
  final bool isLoading;
  final UserProfile? userProfile;
  final String? error;
  final AuthStatus status;

  const AuthState._({
    required this.isLoading,
    this.userProfile,
    this.error,
    required this.status,
  });

  const AuthState.initial() : this._(
    isLoading: true,
    status: AuthStatus.initial,
  );

  const AuthState.loading() : this._(
    isLoading: true,
    status: AuthStatus.loading,
  );

  const AuthState.authenticated(UserProfile profile) : this._(
    isLoading: false,
    userProfile: profile,
    status: AuthStatus.authenticated,
  );

  const AuthState.pendingApproval(UserProfile profile) : this._(
    isLoading: false,
    userProfile: profile,
    status: AuthStatus.pendingApproval,
  );

  const AuthState.unauthenticated() : this._(
    isLoading: false,
    status: AuthStatus.unauthenticated,
  );

  const AuthState.passwordReset() : this._(
    isLoading: false,
    status: AuthStatus.passwordReset,
  );

  const AuthState.error(String errorMessage) : this._(
    isLoading: false,
    error: errorMessage,
    status: AuthStatus.error,
  );

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isPendingApproval => status == AuthStatus.pendingApproval;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isPasswordReset => status == AuthStatus.passwordReset;
  bool get hasError => status == AuthStatus.error;
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  pendingApproval,
  unauthenticated,
  passwordReset,
  error,
}

// ===== PROVIDERS =====

/// Auth state notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Current user profile provider
final currentUserProvider = Provider<UserProfile?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.userProfile;
});

/// Current user role provider
final currentUserRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
});

/// User permissions provider
final userPermissionsProvider = FutureProvider<Map<String, bool>>((ref) async {
  return await AuthService.getUserPermissions();
});

/// Can access dashboard provider
final canAccessDashboardProvider = FutureProvider<bool>((ref) async {
  return await AuthService.canAccessDashboard;
});

/// Can manage users provider
final canManageUsersProvider = FutureProvider<bool>((ref) async {
  return await AuthService.canManageUsers;
});

/// Can assign roles provider
final canAssignRolesProvider = FutureProvider<bool>((ref) async {
  return await AuthService.canAssignRoles;
});

/// Is admin provider
final isAdminProvider = FutureProvider<bool>((ref) async {
  return await AuthService.isAdmin;
});

/// Is manager provider
final isManagerProvider = FutureProvider<bool>((ref) async {
  return await AuthService.isManager;
});

/// Is sales rep provider
final isSalesRepProvider = FutureProvider<bool>((ref) async {
  return await AuthService.isSalesRep;
});

/// Is technician provider
final isTechnicianProvider = FutureProvider<bool>((ref) async {
  return await AuthService.isTechnician;
});

/// Is unassigned provider
final isUnassignedProvider = FutureProvider<bool>((ref) async {
  return await AuthService.isUnassigned;
});

// ===== USER MANAGEMENT PROVIDERS =====

/// All users provider (admin/manager only)
final allUsersProvider = FutureProvider<List<UserProfile>>((ref) async {
  return await AuthService.getAllUsers();
});

/// Unassigned users provider
final unassignedUsersProvider = FutureProvider<List<UserProfile>>((ref) async {
  return await AuthService.getUnassignedUsers();
});

/// Unassigned users count provider
final unassignedUsersCountProvider = Provider<int>((ref) {
  final unassignedUsers = ref.watch(unassignedUsersProvider);
  return unassignedUsers.when(
    data: (users) => users.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// ===== UTILITY PROVIDERS =====

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return AuthService.isAuthenticated;
});

/// Current user ID provider
final currentUserIdProvider = Provider<String?>((ref) {
  return AuthService.userId;
});

/// Current user email provider
final currentUserEmailProvider = Provider<String?>((ref) {
  return AuthService.userEmail;
});

/// Auth state changes stream provider
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return AuthService.authStateChanges.map((authState) {
    if (authState.event == AuthChangeEvent.signedIn) {
      return const AuthState.loading();
    } else if (authState.event == AuthChangeEvent.signedOut) {
      return const AuthState.unauthenticated();
    }
    return const AuthState.initial();
  });
});
