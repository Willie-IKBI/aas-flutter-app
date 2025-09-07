import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../providers/auth_providers.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../../features/auth/presentation/pages/pending_approval_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/password_reset_confirm_page.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
  }

  @override
  void dispose() {
    NotificationService.disposeProfileListener();
    super.dispose();
  }

  void _setupNotificationListener() {
    // Set up real-time listener for profile changes when user is authenticated
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated && authState.userProfile != null) {
      NotificationService.initializeProfileListener(
        authState.userProfile!.id,
        () {
          // Refresh user profile when real-time update is received
          ref.read(authNotifierProvider.notifier).refreshUserProfile();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

// Handle loading state
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    // Handle error state
    if (authState.hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                authState.error ?? 'An unknown error occurred',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).refreshUserProfile();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Note: Password reset handling is now managed by the router
    // AuthWrapper no longer needs to handle password reset scenarios

    // Handle pending approval state
    if (authState.isPendingApproval) {
      return PendingApprovalPage(
        onRefresh: () {
          ref.read(authNotifierProvider.notifier).refreshUserProfile();
        },
      );
    }

    // Handle authenticated state - show appropriate dashboard
    if (authState.isAuthenticated && authState.userProfile != null) {
      return _buildRoleBasedDashboard(authState.userProfile!);
    }

    // Handle unauthenticated state (lowest priority)
    if (authState.isUnauthenticated) {
      return const SignInPage();
    }

    // Fallback to sign in page
    return const SignInPage();
  }

  Widget _buildRoleBasedDashboard(UserProfile userProfile) {
    switch (userProfile.role) {
      case UserRole.admin:
        return const DashboardPage(
          showUserManagement: true,
        );
      case UserRole.manager:
        return const DashboardPage(
          initialTab: 1, // Operations tab
          showUserManagement: true,
        );
      case UserRole.salesRep:
        return const DashboardPage(
          initialTab: 3, // Sales tab
        );
      case UserRole.technician:
        return const DashboardPage(
          initialTab: 2, // Technician tab
        );
      case UserRole.unassigned:
        return PendingApprovalPage(
          onRefresh: () {
            ref.read(authNotifierProvider.notifier).refreshUserProfile();
          },
        );
    }
  }
}
