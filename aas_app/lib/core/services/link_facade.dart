import 'package:flutter/foundation.dart';

// Conditional imports for platform-specific implementations
import 'link_facade_web.dart' if (dart.library.io) 'link_facade_io.dart';

/// Platform-agnostic facade for URL and deep-link operations
///
/// This facade provides a unified interface for URL operations across
/// web and mobile platforms, hiding platform-specific implementations.
abstract class LinkFacade {
  /// Factory constructor that returns the appropriate implementation
  factory LinkFacade() {
    if (kIsWeb) {
      return LinkFacadeWeb();
    } else {
      return LinkFacadeIO();
    }
  }

  /// Get the current URL
  String get currentUrl;

  /// Get URL query parameters as a Map
  Map<String, String> get queryParameters;

  /// Get URL hash/fragment
  String get hash;

  /// Check if current URL contains password recovery parameters
  bool get isPasswordRecoveryUrl;

  /// Clear URL parameters (web only, no-op on mobile)
  void clearUrlParameters();

  /// Reload the current page (web only, no-op on mobile)
  void reloadPage();
}
