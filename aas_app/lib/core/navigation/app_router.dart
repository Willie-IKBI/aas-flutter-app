import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../services/auth_service.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/password_reset_confirm_page.dart';
import '../../features/auth/presentation/pages/pending_approval_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/orders/presentation/pages/create_order_wizard.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/pages/order_management_page.dart';
import '../../features/orders/presentation/pages/active_jobs_page.dart';
import '../../features/parts/presentation/pages/parts_management_page.dart';
import '../../features/parts/presentation/pages/add_part_page.dart';
import '../../features/parts/presentation/pages/part_detail_page.dart';
import '../../features/clients/presentation/pages/client_management_page.dart';
import '../../features/clients/presentation/pages/add_client_page.dart';
import '../../features/clients/presentation/pages/edit_client_page.dart';
import '../../features/admin/presentation/pages/user_management_page.dart';

/// Centralized route names for type-safe navigation
class RouteName {
  // Auth routes
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String passwordReset = '/password-reset';
  static const String pendingApproval = '/pending-approval';

  // Dashboard routes
  static const String dashboard = '/dashboard';
  static const String operations = '/dashboard/operations';
  static const String sales = '/dashboard/sales';
  static const String executive = '/dashboard/executive';
  static const String technician = '/dashboard/technician';

  // Order routes
  static const String orders = '/orders';
  static const String orderCreate = '/orders/create';
  static const String orderDetails = '/orders/details';
  static const String orderManagement = '/orders/management';
  static const String activeJobs = '/orders/active';

  // Parts routes
  static const String parts = '/parts';
  static const String partAdd = '/parts/add';
  static const String partDetails = '/parts/details';

  // Client routes
  static const String clients = '/clients';
  static const String clientAdd = '/clients/add';
  static const String clientEdit = '/clients/edit';

  // Admin routes
  static const String userManagement = '/admin/users';

  // Root route
  static const String root = '/';
}

/// Route parameters for type-safe parameter passing
class RouteParams {
  static const String orderId = 'orderId';
  static const String partId = 'partId';
  static const String clientId = 'clientId';
  static const String userId = 'userId';
}

/// Query parameters for filters and search
class RouteQuery {
  static const String search = 'search';
  static const String filter = 'filter';
  static const String tab = 'tab';
  static const String stage = 'stage';
}

/// App router configuration with auth guards and typed routes
class AppRouter {
  /// Create the router configuration
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: RouteName.root,
      redirect: (context, state) => _handleRedirect(ref, state),
      routes: [
        // Root redirect - redirect to sign-in first, let auth logic handle dashboard
        GoRoute(
          path: RouteName.root,
          redirect: (context, state) => RouteName.signIn,
        ),

        // Auth routes
        GoRoute(
          path: RouteName.signIn,
          name: 'signIn',
          builder: (context, state) => const SignInPage(),
        ),
        GoRoute(
          path: RouteName.signUp,
          name: 'signUp',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: RouteName.forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: RouteName.passwordReset,
          name: 'passwordReset',
          builder: (context, state) {
            // Extract password reset parameters from router state
            final queryParams = state.uri.queryParameters;
            return PasswordResetConfirmPage(
              accessToken: queryParams['access_token'],
              refreshToken: queryParams['refresh_token'],
              token: queryParams['token'],
              code: queryParams['code'],
            );
          },
        ),
        GoRoute(
          path: RouteName.pendingApproval,
          name: 'pendingApproval',
          builder: (context, state) => const PendingApprovalPage(),
        ),

        // Dashboard shell with nested routes
        ShellRoute(
          builder: (context, state, child) => DashboardPage(),
          routes: [
            GoRoute(
              path: RouteName.dashboard,
              name: 'dashboard',
              builder: (context, state) =>
                  const SizedBox.shrink(), // Handled by shell
              routes: [
                GoRoute(
                  path: 'operations',
                  name: 'operations',
                  builder: (context, state) => const SizedBox.shrink(),
                ),
                GoRoute(
                  path: 'sales',
                  name: 'sales',
                  builder: (context, state) => const SizedBox.shrink(),
                ),
                GoRoute(
                  path: 'executive',
                  name: 'executive',
                  builder: (context, state) => const SizedBox.shrink(),
                ),
                GoRoute(
                  path: 'technician',
                  name: 'technician',
                  builder: (context, state) => const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),

        // Order routes
        GoRoute(
          path: RouteName.orders,
          name: 'orders',
          builder: (context, state) => const OrderManagementPage(),
        ),
        GoRoute(
          path: RouteName.orderCreate,
          name: 'orderCreate',
          builder: (context, state) => const CreateOrderWizard(),
        ),
        GoRoute(
          path: '${RouteName.orderDetails}/:${RouteParams.orderId}',
          name: 'orderDetails',
          builder: (context, state) {
            final orderId = state.pathParameters[RouteParams.orderId]!;
            return OrderDetailsPage(orderId: int.parse(orderId));
          },
        ),
        GoRoute(
          path: RouteName.orderManagement,
          name: 'orderManagement',
          builder: (context, state) => const OrderManagementPage(),
        ),
        GoRoute(
          path: RouteName.activeJobs,
          name: 'activeJobs',
          builder: (context, state) => const ActiveJobsPage(),
        ),

        // Parts routes
        GoRoute(
          path: RouteName.parts,
          name: 'parts',
          builder: (context, state) => const PartsManagementPage(),
        ),
        GoRoute(
          path: RouteName.partAdd,
          name: 'partAdd',
          builder: (context, state) => const AddPartPage(),
        ),
        GoRoute(
          path: '${RouteName.partDetails}/:${RouteParams.partId}',
          name: 'partDetails',
          builder: (context, state) {
            final partId = state.pathParameters[RouteParams.partId]!;
            return PartDetailPage(partId: partId);
          },
        ),

        // Client routes
        GoRoute(
          path: RouteName.clients,
          name: 'clients',
          builder: (context, state) => const ClientManagementPage(),
        ),
        GoRoute(
          path: RouteName.clientAdd,
          name: 'clientAdd',
          builder: (context, state) => const AddClientPage(),
        ),
        GoRoute(
          path: '${RouteName.clientEdit}/:${RouteParams.clientId}',
          name: 'clientEdit',
          builder: (context, state) {
            final clientId = state.pathParameters[RouteParams.clientId]!;
            return EditClientPage(clientId: clientId);
          },
        ),

        // Admin routes
        GoRoute(
          path: RouteName.userManagement,
          name: 'userManagement',
          builder: (context, state) => const UserManagementPage(),
        ),
      ],
      errorBuilder: (context, state) => _buildErrorPage(context, state),
    );
  }

  /// Handle redirects based on auth state and URL parameters
  static String? _handleRedirect(WidgetRef ref, GoRouterState state) {
    final authState = ref.read(authNotifierProvider);
    final isSignedIn = authState.isAuthenticated;
    final isPendingApproval = authState.isPendingApproval;
    final supabaseAuthenticated = AuthService.isAuthenticated;

    // Check for password recovery parameters in URL
    final hasRecoveryParams = _hasPasswordRecoveryParams(state.uri);
    if (hasRecoveryParams && state.uri.path != RouteName.passwordReset) {
      return RouteName.passwordReset;
    }

    // Handle pending approval
    if (isPendingApproval) {
      if (state.uri.path != RouteName.pendingApproval) {
        return RouteName.pendingApproval;
      }
      return null; // Stay on pending approval page
    }

    // Handle authentication redirects
    if (!isSignedIn && !supabaseAuthenticated) {
      // Not signed in - redirect to sign in unless already on auth pages or password reset
      if (!_isAuthRoute(state.uri.path) &&
          state.uri.path != RouteName.passwordReset) {
        return RouteName.signIn;
      }
    } else if (isSignedIn || supabaseAuthenticated) {
      // Signed in - redirect away from auth pages (but allow password reset)
      if (_isAuthRoute(state.uri.path) &&
          state.uri.path != RouteName.passwordReset) {
        return RouteName.dashboard;
      }
    }

    return null; // No redirect needed
  }

  /// Check if URL contains password recovery parameters
  static bool _hasPasswordRecoveryParams(Uri uri) {
    final queryParams = uri.queryParameters;
    return queryParams.containsKey('access_token') ||
        queryParams.containsKey('refresh_token') ||
        queryParams.containsKey('token') ||
        queryParams.containsKey('code') ||
        (queryParams.containsKey('type') &&
            queryParams['type'] == 'recovery') ||
        uri.path.contains('reset-password') ||
        uri.path.contains('recovery') ||
        uri.fragment.contains('reset-password') ||
        uri.fragment.contains('recovery');
  }

  /// Check if the current path is an auth route
  static bool _isAuthRoute(String path) {
    return path == RouteName.signIn ||
        path == RouteName.signUp ||
        path == RouteName.forgotPassword ||
        path == RouteName.passwordReset ||
        path == RouteName.pendingApproval;
  }

  /// Build error page for unknown routes
  static Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri.path}" could not be found.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteName.dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Route helper extensions for easy navigation
extension AppRouterExtensions on BuildContext {
  // Auth navigation
  void goToSignIn() => go(RouteName.signIn);
  void goToSignUp() => go(RouteName.signUp);
  void goToForgotPassword() => go(RouteName.forgotPassword);
  void goToPasswordReset() => go(RouteName.passwordReset);

  // Dashboard navigation
  void goToDashboard() => go(RouteName.dashboard);
  void goToOperations() => go(RouteName.operations);
  void goToSales() => go(RouteName.sales);
  void goToExecutive() => go(RouteName.executive);
  void goToTechnician() => go(RouteName.technician);

  // Order navigation
  void goToOrders() => go(RouteName.orders);
  void goToOrderCreate() => go(RouteName.orderCreate);
  void goToOrderDetails(String orderId) =>
      go('${RouteName.orderDetails}/$orderId');
  void goToOrderManagement() => go(RouteName.orderManagement);
  void goToActiveJobs() => go(RouteName.activeJobs);

  // Parts navigation
  void goToParts() => go(RouteName.parts);
  void goToPartAdd() => go(RouteName.partAdd);
  void goToPartDetails(String partId) => go('${RouteName.partDetails}/$partId');

  // Client navigation
  void goToClients() => go(RouteName.clients);
  void goToClientAdd() => go(RouteName.clientAdd);
  void goToClientEdit(String clientId) =>
      go('${RouteName.clientEdit}/$clientId');

  // Admin navigation
  void goToUserManagement() => go(RouteName.userManagement);

  // Back navigation
  void goBack() => pop();
}
