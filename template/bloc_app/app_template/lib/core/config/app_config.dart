class AppConfig {
  const AppConfig({
    required this.appName,
    required this.environment,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.useMockApi,
  });

  final String appName;
  final String environment;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool useMockApi;

  factory AppConfig.fromEnvironment() {
    const appName = String.fromEnvironment(
      'APP_NAME',
      defaultValue: '__APP_NAME__',
    );
    const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://example.com/api',
    );
    const enableLogging = bool.fromEnvironment(
      'ENABLE_LOGGING',
      defaultValue: true,
    );
    const useMockApi = bool.fromEnvironment('USE_MOCK_API', defaultValue: true);

    return const AppConfig(
      appName: appName,
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      enableLogging: enableLogging,
      useMockApi: useMockApi,
    );
  }
}
