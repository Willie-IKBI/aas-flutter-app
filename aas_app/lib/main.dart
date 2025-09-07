import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'core/config/supabase_config.dart';
import 'core/theme/index.dart';
import 'core/navigation/app_router.dart';
import 'core/services/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handling
  _setupErrorHandling();

  try {
    // Initialize Supabase
    await SupabaseConfig.initialize();

    runApp(
      const ProviderScope(
        child: AASApp(),
      ),
    );
  } catch (error) {
    // Log initialization error
    final logger = Logger('AppInitialization');
    logger.critical('App initialization failed', error: error);

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
                  onPressed: () {
                    // Simple retry by reloading the page
                    runApp(
                      const ProviderScope(
                        child: AASApp(),
                      ),
                    );
                  },
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

/// Set up global error handling for Flutter and async errors
void _setupErrorHandling() {
  final logger = Logger('ErrorHandling');

  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
      data: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );

    // In debug mode, also print to console
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  // Handle async errors with runZonedGuarded
  runZonedGuarded(
    () {
      // App will run here - this is handled by the main() function
    },
    (error, stackTrace) {
      logger.critical(
        'Uncaught async error',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

class AASApp extends ConsumerWidget {
  const AASApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter.createRouter(ref);

    return MaterialApp.router(
      title: 'All Africa Supplies',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
