import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../data/database/app_database.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';

class AuthModule {
  void register(GetIt getIt) {
    getIt
      ..registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSource(getIt<AuthDao>()),
      )
      ..registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSource(getIt<ApiClient>()),
      )
      ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
          remote: getIt<AuthRemoteDataSource>(),
          local: getIt<AuthLocalDataSource>(),
          networkInfo: getIt<NetworkInfo>(),
        ),
      )
      ..registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  }
}
