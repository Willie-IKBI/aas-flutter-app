import 'dart:html' as html;

/// Web implementation of LinkFacade using dart:html
class LinkFacadeWeb implements LinkFacade {
  @override
  String get currentUrl => html.window.location.href;

  @override
  Map<String, String> get queryParameters {
    final uri = Uri.parse(currentUrl);
    return uri.queryParameters;
  }

  @override
  String get hash => html.window.location.hash;

  @override
  bool get isPasswordRecoveryUrl {
    final uri = Uri.parse(currentUrl);
    final queryParams = uri.queryParameters;

    // Check for password recovery parameters
    return queryParams.containsKey('access_token') ||
        queryParams.containsKey('refresh_token') ||
        queryParams.containsKey('token') ||
        queryParams.containsKey('code') ||
        queryParams['type'] == 'recovery';
  }

  @override
  void clearUrlParameters() {
    try {
      // Remove URL parameters after successful password reset
      final currentUri = Uri.parse(currentUrl);
      final newUri = Uri(
        scheme: currentUri.scheme,
        host: currentUri.host,
        port: currentUri.port,
        path: currentUri.path,
        fragment: currentUri.fragment,
      );

      html.window.history.replaceState(null, '', newUri.toString());
    } catch (e) {}
  }

  @override
  void reloadPage() {
    html.window.location.reload();
  }
}
