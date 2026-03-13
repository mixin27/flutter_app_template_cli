import 'package:app_logger/app_logger.dart';
import 'package:get_it/get_it.dart';

import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../auth/access/auth_access_strategy.dart';
import '../../auth/access/auth_feature_registry.dart';
import '../../config/app_config.dart';
import '../../router/app_router.dart';
import 'dependency_module.dart';
import 'get_it_extensions.dart';

class RouterModule implements DependencyModule {
  const RouterModule();

  @override
  void register(GetIt getIt) {
    final appConfig = getIt<AppConfig>();

    getIt.putLazySingletonIfAbsent<AppRouter>(
      () => AppRouter(
        authBloc: getIt<AuthBloc>(),
        authAccessStrategy: getIt<AuthAccessStrategy>(),
        authFeatureRegistry: getIt<AuthFeatureRegistry>(),
        appLogger: getIt<AppLogger>(),
        enableLogDevTools: appConfig.isDevelopment,
      ),
    );
  }
}
