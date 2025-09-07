/// IO implementation of LinkFacade for mobile/desktop platforms
///
/// This implementation provides no-op methods since mobile/desktop
/// platforms don't have URL manipulation capabilities like web.
class LinkFacadeIO implements LinkFacade {
  @override
  String get currentUrl => '';

  @override
  Map<String, String> get queryParameters => {};

  @override
  String get hash => '';

  @override
  bool get isPasswordRecoveryUrl => false;

  @override
  void clearUrlParameters() {
    // No-op on mobile/desktop platforms
  }

  @override
  void reloadPage() {
    // No-op on mobile/desktop platforms
  }
}
