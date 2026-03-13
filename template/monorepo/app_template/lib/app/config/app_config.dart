import 'package:equatable/equatable.dart';

import '../auth/access/auth_feature_ids.dart';
import 'app_envied.dart';
import 'app_environment.dart';
import 'auth_gate_mode.dart';

class AppConfig extends Equatable {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableSampleSeedData,
    required this.enableVerboseStartupLogs,
    required this.authGateMode,
    required this.requiredAuthFeatures,
  });

  factory AppConfig.fromEnvironment({AppEnvironment? environmentOverride}) {
    const defaultRequiredAuthFeatures =
        '${AuthFeatureIds.tasks},${AuthFeatureIds.profile}';

    final environment =
        environmentOverride ??
        AppEnvironment.fromString(
          _resolveString(
            defineValue: const bool.hasEnvironment('APP_ENV')
                ? const String.fromEnvironment('APP_ENV')
                : null,
            enviedValue: AppEnvied.appEnv,
            defaultValue: 'production',
          ),
        );

    final apiBaseUrl = _resolveString(
      defineValue: const bool.hasEnvironment('API_BASE_URL')
          ? const String.fromEnvironment('API_BASE_URL')
          : null,
      enviedValue: AppEnvied.apiBaseUrl,
      defaultValue: _defaultBaseUrlFor(environment),
    );

    final enableSampleSeedData = _resolveBool(
      defineValue: const bool.hasEnvironment('ENABLE_SAMPLE_SEED_DATA')
          ? const bool.fromEnvironment('ENABLE_SAMPLE_SEED_DATA')
          : null,
      enviedValue: AppEnvied.enableSampleSeedData,
      defaultValue: environment != AppEnvironment.production,
    );

    final enableVerboseStartupLogs = _resolveBool(
      defineValue: const bool.hasEnvironment('ENABLE_VERBOSE_STARTUP_LOGS')
          ? const bool.fromEnvironment('ENABLE_VERBOSE_STARTUP_LOGS')
          : null,
      enviedValue: AppEnvied.enableVerboseStartupLogs,
      defaultValue: environment != AppEnvironment.production,
    );

    final authGateMode = AuthGateMode.fromString(
      _resolveString(
        defineValue: const bool.hasEnvironment('AUTH_GATE_MODE')
            ? const String.fromEnvironment('AUTH_GATE_MODE')
            : null,
        enviedValue: AppEnvied.authGateMode,
        defaultValue: 'feature_scoped',
      ),
    );

    final requiredAuthFeatures = _parseRequiredAuthFeatures(
      _resolveString(
        defineValue: const bool.hasEnvironment('AUTH_REQUIRED_FEATURES')
            ? const String.fromEnvironment('AUTH_REQUIRED_FEATURES')
            : null,
        enviedValue: AppEnvied.authRequiredFeatures,
        defaultValue: defaultRequiredAuthFeatures,
      ),
    );

    return AppConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      enableSampleSeedData: enableSampleSeedData,
      enableVerboseStartupLogs: enableVerboseStartupLogs,
      authGateMode: authGateMode,
      requiredAuthFeatures: requiredAuthFeatures,
    );
  }

  final AppEnvironment environment;
  final String apiBaseUrl;
  final bool enableSampleSeedData;
  final bool enableVerboseStartupLogs;
  final AuthGateMode authGateMode;
  final Set<String> requiredAuthFeatures;

  bool get isDevelopment => environment == AppEnvironment.development;

  bool get isProduction => environment == AppEnvironment.production;

  @override
  List<Object?> get props => [
    environment,
    apiBaseUrl,
    enableSampleSeedData,
    enableVerboseStartupLogs,
    authGateMode,
    requiredAuthFeatures,
  ];

  static String _defaultBaseUrlFor(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.development:
        return 'https://dev-api.example.com/v1';
      case AppEnvironment.staging:
        return 'https://staging-api.example.com/v1';
      case AppEnvironment.production:
        return 'https://api.example.com/v1';
    }
  }

  static Set<String> _parseRequiredAuthFeatures(String rawValue) {
    return rawValue
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  static String _resolveString({
    required String? defineValue,
    required String enviedValue,
    required String defaultValue,
  }) {
    final defineCandidate = defineValue?.trim();
    if (defineCandidate != null && defineCandidate.isNotEmpty) {
      return defineCandidate;
    }

    final enviedCandidate = enviedValue.trim();
    if (enviedCandidate.isNotEmpty) {
      return enviedCandidate;
    }

    return defaultValue;
  }

  static bool _resolveBool({
    required bool? defineValue,
    required String enviedValue,
    required bool defaultValue,
  }) {
    if (defineValue != null) {
      return defineValue;
    }

    final enviedBool = _parseOptionalBool(enviedValue);
    if (enviedBool != null) {
      return enviedBool;
    }

    return defaultValue;
  }

  static bool? _parseOptionalBool(String rawValue) {
    final normalized = rawValue.trim().toLowerCase();
    switch (normalized) {
      case '1':
      case 'true':
      case 'yes':
      case 'y':
      case 'on':
        return true;
      case '0':
      case 'false':
      case 'no':
      case 'n':
      case 'off':
        return false;
      default:
        return null;
    }
  }
}
