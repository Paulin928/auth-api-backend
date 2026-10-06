class Env {
  /// Base URL de l'API Rust.
  ///
  /// - Web (Chrome dans Codespaces) : utiliser l'URL publique du port 3000
  ///   (ex: https://<codespace>-3000.app.github.dev)
  /// - Android émulateur : http://10.0.2.2:3000
  /// - iOS simulateur   : http://localhost:3000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
