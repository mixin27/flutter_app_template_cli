import 'package:app_logger/app_logger.dart';
import 'package:app_network/app_network.dart';
import 'package:app_storage/app_storage.dart';
import 'package:get_it/get_it.dart';

import '../../../core/database/app_database.dart';
import '../../auth/access/auth_access_strategy.dart';
import '../../auth/access/auth_feature_ids.dart';
import '../../auth/access/auth_feature_registry.dart';
import '../../config/app_config.dart';
import '../../router/app_route_paths.dart';
import 'dependency_module.dart';
import 'get_it_extensions.dart';

class AppCoreModule implements DependencyModule {
  const AppCoreModule({
    required this.appConfig,
    required this.appLogger,
    required this.sharedPreferencesService,
  });

  final AppConfig appConfig;
  final AppLogger appLogger;
  final SharedPreferencesService sharedPreferencesService;

  @override
  void register(GetIt getIt) {
    getIt
      ..putSingletonIfAbsent<AppConfig>(appConfig)
      ..putSingletonIfAbsent<AppLogger>(appLogger)
      ..putSingletonIfAbsent<SharedPreferencesService>(sharedPreferencesService)
      ..putLazySingletonIfAbsent<AuthFeatureRegistry>(
        () => const AuthFeatureRegistry(
          rules: {
            AuthFeatureRule(
              featureId: AuthFeatureIds.tasks,
              routePrefixes: {AppRoutePaths.tasks},
            ),
            AuthFeatureRule(
              featureId: AuthFeatureIds.profile,
              routePrefixes: {AppRoutePaths.profile},
            ),
          },
        ),
      )
      ..putLazySingletonIfAbsent<AuthAccessStrategy>(
        () => AuthAccessStrategyFactory.fromMode(
          appConfig.authGateMode,
          requiredFeatures: appConfig.requiredAuthFeatures,
        ),
      )
      ..putLazySingletonIfAbsent<AppDatabase>(AppDatabase.new)
      ..putLazySingletonIfAbsent<SecureStorageService>(
        FlutterSecureStorageService.new,
      )
      ..putLazySingletonIfAbsent<AuthTokenStore>(
        () => SecureAuthTokenStore(getIt<SecureStorageService>()),
      );
  }
}
