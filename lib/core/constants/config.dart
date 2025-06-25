// ignore_for_file: avoid_classes_with_only_static_members

/// Config for app.
abstract final class Config {
  // --- ENVIRONMENT --- //

  /// Environment flavor.
  static final EnvironmentFlavor environment = EnvironmentFlavor.from(
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development'),
  );

  // --- API --- //

  /// Base url for api.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://api.domain.tld');

  /// Timeout for opening url.
  static const Duration apiConnectTimeout = Duration(
    milliseconds:
        int.fromEnvironment('API_CONNECT_TIMEOUT', defaultValue: 15000),
  );

  /// Timeout for receiving data.
  static const Duration apiReceiveTimeout = Duration(
    milliseconds:
        int.fromEnvironment('API_RECEIVE_TIMEOUT', defaultValue: 10000),
  );

  /// DSN для Sentry.
  static const String sentryDSN =
      String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  /// ────────── Telegram (добавлено) ──────────
  static const String telegramBotToken =
      String.fromEnvironment('TELEGRAM_BOT_TOKEN', defaultValue: '');
  static const String telegramChatId =
      String.fromEnvironment('TELEGRAM_CHAT_ID', defaultValue: '');
  // ───────────────────────────────────────────

  // --- AUTHENTICATION --- //

  static const int passwordMinLength =
      int.fromEnvironment('PASSWORD_MIN_LENGTH', defaultValue: 8);

  static const int passwordMaxLength =
      int.fromEnvironment('PASSWORD_MAX_LENGTH', defaultValue: 32);

  // --- LAYOUT --- //

  static const int maxScreenLayoutWidth =
      int.fromEnvironment('MAX_LAYOUT_WIDTH', defaultValue: 768);

  // --- Key storage namespace --- //

  static const String storageNamespace = 'kinza';

  static const String versionMajorKey = '$storageNamespace.version.major';
  static const String versionMinorKey = '$storageNamespace.version.minor';
  static const String versionPatchKey = '$storageNamespace.version.patch';
}

/// Environment flavor.
enum EnvironmentFlavor {
  development('development'),
  staging('staging'),
  production('production');

  const EnvironmentFlavor(this.value);

  factory EnvironmentFlavor.from(String? value) =>
      switch (value?.trim().toLowerCase()) {
        'development' || 'debug' || 'develop' || 'dev' => development,
        'staging' || 'profile' || 'stage' || 'stg' => staging,
        'production' || 'release' || 'prod' || 'prd' => production,
        _ => const bool.fromEnvironment('dart.vm.product')
            ? production
            : development,
      };

  final String value;

  bool get isDevelopment => this == development;
  bool get isStaging => this == staging;
  bool get isProduction => this == production;
}
