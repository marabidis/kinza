// ignore_for_file: avoid_classes_with_only_static_members

/// Config for app.
abstract final class Config {
  // --- ENVIRONMENT --- //

  /// Environment flavor.
  /// e.g. development, staging, production
  static final EnvironmentFlavor environment = EnvironmentFlavor.from(
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development'),
  );

  // --- API --- //

  /// Base url for api.
  /// e.g. https://api.domain.tld
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://api.domain.tld');

  /// Timeout in milliseconds for opening url.
  /// [Dio] will throw the [DioException] with [DioExceptionType.connectTimeout] type when time out.
  /// e.g. 15000
  static const Duration apiConnectTimeout = Duration(
    milliseconds:
        int.fromEnvironment('API_CONNECT_TIMEOUT', defaultValue: 15000),
  );

  /// Timeout in milliseconds for receiving data from url.
  /// [Dio] will throw the [DioException] with [DioExceptionType.receiveTimeout] type when time out.
  /// e.g. 10000
  static const Duration apiReceiveTimeout = Duration(
    milliseconds:
        int.fromEnvironment('API_RECEIVE_TIMEOUT', defaultValue: 10000),
  );

  /// The client key for sentry SDK. The DSN tells the SDK where to send the events to.
  static const String sentryDSN =
      String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  // --- AUTHENTICATION --- //

  /// Minimum length of password.
  /// e.g. 8
  static const int passwordMinLength =
      int.fromEnvironment('PASSWORD_MIN_LENGTH', defaultValue: 8);

  /// Maximum length of password.
  /// e.g. 32
  static const int passwordMaxLength =
      int.fromEnvironment('PASSWORD_MAX_LENGTH', defaultValue: 32);

  // --- LAYOUT --- //

  /// Maximum screen layout width for screen with list view.
  static const int maxScreenLayoutWidth =
      int.fromEnvironment('MAX_LAYOUT_WIDTH', defaultValue: 768);

  // --- Key storage namespace --- //

  /// Namespace for all version keys
  static const String storageNamespace = 'kinza';

  /// Keys for storing the current version of the app
  static const String versionMajorKey = '$storageNamespace.version.major';

  /// Keys for storing the current version of the app
  static const String versionMinorKey = '$storageNamespace.version.minor';

  /// Keys for storing the current version of the app
  static const String versionPatchKey = '$storageNamespace.version.patch';
}

/// Environment flavor.
/// e.g. development, staging, production
enum EnvironmentFlavor {
  /// Development
  development('development'),

  /// Staging
  staging('staging'),

  /// Production
  production('production');

  /// Create environment flavor.
  const EnvironmentFlavor(this.value);

  /// Create environment flavor from string.
  factory EnvironmentFlavor.from(String? value) =>
      switch (value?.trim().toLowerCase()) {
        'development' || 'debug' || 'develop' || 'dev' => development,
        'staging' || 'profile' || 'stage' || 'stg' => staging,
        'production' || 'release' || 'prod' || 'prd' => production,
        _ => const bool.fromEnvironment('dart.vm.product')
            ? production
            : development,
      };

  /// development, staging, production
  final String value;

  /// Whether the environment is development.
  bool get isDevelopment => this == development;

  /// Whether the environment is staging.
  bool get isStaging => this == staging;

  /// Whether the environment is production.
  bool get isProduction => this == production;
}
