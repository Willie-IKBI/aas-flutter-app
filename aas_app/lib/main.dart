import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/index.dart';
import 'core/widgets/auth_wrapper.dart';
import 'core/providers/auth_providers.dart';
import 'features/auth/presentation/pages/password_reset_confirm_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Supabase
    await SupabaseConfig.initialize();
    
    runApp(
      const ProviderScope(
        child: AASApp(),
      ),
    );
  } catch (error) {
    print('❌ Initialization error: $error');
    // Fallback app for initialization errors
    runApp(
      MaterialApp(
        title: 'All Africa Supplies',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to initialize app: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => html.window.location.reload(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AASApp extends ConsumerStatefulWidget {
  const AASApp({super.key});

  @override
  ConsumerState<AASApp> createState() => _AASAppState();
}

class _AASAppState extends ConsumerState<AASApp> {
  Timer? _urlCheckTimer;
  
  @override
  void initState() {
    super.initState();
    _checkForPasswordReset();
    _setupUrlListener();
  }

  @override
  void dispose() {
    _urlCheckTimer?.cancel();
    super.dispose();
  }

  void _setupUrlListener() {
    // Check URL periodically and on various events
    _urlCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _checkForPasswordReset();
    });
    
    // Listen for popstate events (back/forward navigation)
    html.window.addEventListener('popstate', (event) {
      print('🔍 AASApp - Popstate event detected');
      _checkForPasswordReset();
    });
    
    // Listen for hashchange events
    html.window.addEventListener('hashchange', (event) {
      print('🔍 AASApp - Hashchange event detected');
      _checkForPasswordReset();
    });
    
    // Listen for beforeunload events (when page is about to unload)
    html.window.addEventListener('beforeunload', (event) {
      print('🔍 AASApp - Beforeunload event detected');
      _checkForPasswordReset();
    });
  }

  void _checkForPasswordReset() {
    // Check if the current URL contains password reset parameters
    final currentUrl = html.window.location.href;
    final uri = Uri.parse(currentUrl);
    
    print('🔍 AASApp - Current URL: $currentUrl');
    print('🔍 AASApp - URI path: ${uri.path}');
    print('🔍 AASApp - URI query parameters: ${uri.queryParameters}');
    print('🔍 AASApp - URI fragment: ${uri.fragment}');
    
    // Check for various password reset URL patterns
    final hasResetParams = uri.queryParameters.containsKey('access_token') ||
                          uri.queryParameters.containsKey('refresh_token') ||
                          uri.queryParameters.containsKey('token') ||
                          uri.queryParameters.containsKey('code') ||
                          (uri.queryParameters.containsKey('type') && uri.queryParameters['type'] == 'recovery') ||
                          uri.path.contains('reset-password') ||
                          uri.path.contains('recovery') ||
                          uri.fragment.contains('reset-password') ||
                          uri.fragment.contains('recovery') ||
                          currentUrl.contains('type=recovery') ||
                          currentUrl.contains('access_token=') ||
                          currentUrl.contains('refresh_token=') ||
                          currentUrl.contains('token=') ||
                          currentUrl.contains('code=') ||
                          currentUrl.contains('reset-password') ||
                          currentUrl.contains('recovery');
    
    print('🔍 AASApp - Has reset params: $hasResetParams');
    print('🔍 AASApp - Checking individual params:');
    print('  - access_token: ${uri.queryParameters.containsKey('access_token')}');
    print('  - refresh_token: ${uri.queryParameters.containsKey('refresh_token')}');
    print('  - token: ${uri.queryParameters.containsKey('token')}');
    print('  - code: ${uri.queryParameters.containsKey('code')}');
    print('  - type=recovery: ${uri.queryParameters.containsKey('type') && uri.queryParameters['type'] == 'recovery'}');
    
    if (hasResetParams) {
      print('🔍 AASApp - Password reset URL detected! Setting password reset state...');
      // Set the password reset state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authNotifierProvider.notifier).setPasswordResetState();
      });
    } else {
      print('🔍 AASApp - No password reset parameters found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All Africa Supplies',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/', // Normal authentication flow
      routes: {
        '/': (context) => const AuthWrapper(),
        '/reset-password': (context) => const PasswordResetConfirmPage(),
      },
      onGenerateRoute: (settings) {
        // Handle password reset links from email
        if (settings.name?.startsWith('/reset-password') == true ||
            settings.name?.contains('reset-password') == true) {
          return MaterialPageRoute(
            builder: (context) => const PasswordResetConfirmPage(),
          );
        }
        
        // Handle hash-based routing for password reset
        if (settings.name?.contains('#/reset-password') == true) {
          return MaterialPageRoute(
            builder: (context) => const PasswordResetConfirmPage(),
          );
        }
        
        // Default route
        return MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
        );
      },
    );
  }
}




