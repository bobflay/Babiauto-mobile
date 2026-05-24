/// Base URL of the Babiauto Laravel API (`/api/v1`).
///
/// Override at build/run time, e.g.:
///   flutter run --dart-define=API_BASE_URL=https://api.babiauto.ci/api/v1
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  /// Demo rider seeded by `php artisan migrate --seed`.
  static const String demoEmail = String.fromEnvironment(
    'DEMO_EMAIL',
    defaultValue: 'koffi@babiauto.ci',
  );
  static const String demoPassword = String.fromEnvironment(
    'DEMO_PASSWORD',
    defaultValue: 'password',
  );

  static const Duration timeout = Duration(seconds: 8);
}
