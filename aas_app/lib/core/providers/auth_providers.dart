import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';

// ===== AUTH STATE MANAGEMENT =====

/// Auth state notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial()) {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
// Check current auth state first
    _checkInitialAuthState();

    // Then listen for changes
    AuthService.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn) {
        _loadUserProfile();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        state = const AuthState.unauthenticated();
      } else if (authState.event == AuthChangeEvent.passwordRecovery) {
        state = const AuthState.passwordReset();
      } else if (authState.event == AuthChangeEvent.initialSession) {
// Check if this initial session is from a password recovery
        _checkForPasswordRecoverySession();
      } else if (authState.event == AuthChangeEvent.userUpdated) {
        // After password update, check if user has a profile
        _loadUserProfile();
      }
    });
  }

  Future<void> _checkInitialAuthState() async {
// Check if user is already signed in
    if (AuthService.isAuthenticated) {
      await _loadUserProfile();
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> _loadUserProfile() async {
    state = const AuthState.loading();

    try {
      final profile = await AuthService.getCurrentUserProfile();

      if (profile != null) {
        if (profile.isUnassigned) {
          state = AuthState.pendingApproval(profile);
        } else {
          state = AuthState.authenticated(profile);
        }
      } else {
        // Profile not found, but user is authenticated via Supabase
        // Create a minimal profile for authenticated state
        final user = AuthService.currentUser;
        if (user != null) {
          final minimalProfile = UserProfile(
            id: user.id,
            email: user.email ?? '',
            displayName: user.userMetadata?['display_name'] ?? user.email ?? 'User',
            role: UserRole.technician, // Default role
            createdAt: DateTime.now(),
            status: 'active',
          );
          state = AuthState.authenticated(minimalProfile);
        } else {
          state = const AuthState.unauthenticated();
        }
      }
    } catch (e) {
      // Profile loading failed, but user is authenticated via Supabase
      // Create a minimal profile for authenticated state
      final user = AuthService.currentUser;
      if (user != null) {
        final minimalProfile = UserProfile(
          id: user.id,
          email: user.email ?? '',
          displayName: user.userMetadata?['display_name'] ?? user.email ?? 'User',
          role: UserRole.technician, // Default role
          createdAt: DateTime.now(),
          status: 'active',
        );
        state = AuthState.authenticated(minimalProfile);
      } else {
        state = AuthState.error(e.toString());
      }
    }
  }

  Future<void> refreshUserProfile() async {
    await _loadUserProfile();
  }

  Future<void> _checkForPasswordRecoverySession() async {
    // Check if this is a password recovery session
    // This method is a placeholder for future password recovery logic
    // Currently handled by the router
  }

  Future<void> signOut() async {
    try {
      await AuthService.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  // Note: Password reset state management is now handled by the router
  // This method is deprecated and will be removed in future versions
}

/// Auth state representing different authentication states
class AuthState {
  const AuthState._({
    required this.isLoading,
    this.userProfile,
    this.error,
    required this.status,
  });

  const AuthState.initial()
      : this._(
          isLoading: true,
          status: AuthStatus.initial,
        );

  const AuthState.loading()
      : this._(
          isLoading: true,
          status: AuthStatus.loading,
        );

  const AuthState.authenticated(UserProfile profile)
      : this._(
          isLoading: false,
          userProfile: profile,
          status: AuthStatus.authenticated,
        );

  const AuthState.pendingApproval(UserProfile profile)
      : this._(
          isLoading: false,
          userProfile: profile,
          status: AuthStatus.pendingApproval,
        );

  const AuthState.unauthenticated()
      : this._(
          isLoading: false,
          status: AuthStatus.unauthenticated,
        );

  const AuthState.passwordReset()
      : this._(
          isLoading: false,
          status: AuthStatus.passwordReset,
        );

  const AuthState.error(String errorMessage)
      : this._(
          isLoading: false,
          error: errorMessage,
          status: AuthStatus.error,
        );
  final bool isLoading;
  final UserProfile? userProfile;
  final String? error;
  final AuthStatus status;

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
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
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
