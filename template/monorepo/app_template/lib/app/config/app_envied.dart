import 'package:envied/envied.dart';

part 'app_envied.g.dart';

@Envied(path: '.env', requireEnvFile: false)
abstract final class AppEnvied {
  @EnviedField(varName: 'APP_ENV', defaultValue: '')
  static const String appEnv = _AppEnvied.appEnv;

  @EnviedField(varName: 'API_BASE_URL', defaultValue: '')
  static const String apiBaseUrl = _AppEnvied.apiBaseUrl;

  @EnviedField(varName: 'ENABLE_SAMPLE_SEED_DATA', defaultValue: '')
  static const String enableSampleSeedData = _AppEnvied.enableSampleSeedData;

  @EnviedField(varName: 'ENABLE_VERBOSE_STARTUP_LOGS', defaultValue: '')
  static const String enableVerboseStartupLogs =
      _AppEnvied.enableVerboseStartupLogs;

  @EnviedField(varName: 'AUTH_GATE_MODE', defaultValue: '')
  static const String authGateMode = _AppEnvied.authGateMode;

  @EnviedField(varName: 'AUTH_REQUIRED_FEATURES', defaultValue: '')
  static const String authRequiredFeatures = _AppEnvied.authRequiredFeatures;
}
