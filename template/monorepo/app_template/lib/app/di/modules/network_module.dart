import 'package:app_logger/app_logger.dart';
import 'package:app_network/app_network.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../features/auth/domain/usecases/refresh_session_use_case.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../config/app_config.dart';
import 'dependency_module.dart';
import 'get_it_extensions.dart';

class NetworkModule implements DependencyModule {
  const NetworkModule();

  @override
  void register(GetIt getIt) {
    final appConfig = getIt<AppConfig>();

    getIt
      ..putLazySingletonIfAbsent<Dio>(
        () => DioFactory.create(
          config: NetworkConfig(baseUrl: appConfig.apiBaseUrl),
          authTokenStore: getIt<AuthTokenStore>(),
          refreshTokens: (refreshToken) async {
            final result = await getIt<RefreshSessionUseCase>()(
              RefreshSessionParams(refreshToken),
            );
            return result.fold((failure) {
              getIt<AppLogger>().warning(
                '[Auth] Token refresh failed: ${failure.message}',
              );
              return null;
            }, (tokens) => tokens);
          },
          onSessionExpired: () async {
            getIt<AppLogger>().warning('[Auth] Session expired');
            if (getIt.isRegistered<AuthBloc>()) {
              getIt<AuthBloc>().add(const SessionExpired());
            }
          },
          enableDebugLogs: !appConfig.isProduction,
        ),
      )
      ..putLazySingletonIfAbsent<ApiClient>(() => ApiClient(getIt<Dio>()));
  }
}
