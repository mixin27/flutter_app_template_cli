import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../data/database/app_database.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';

class ProfileModule {
  void register(GetIt getIt) {
    getIt
      ..registerLazySingleton<ProfileLocalDataSource>(
        () => ProfileLocalDataSource(getIt<ProfilesDao>()),
      )
      ..registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSource(getIt<ApiClient>()),
      )
      ..registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(
          remote: getIt<ProfileRemoteDataSource>(),
          local: getIt<ProfileLocalDataSource>(),
          networkInfo: getIt<NetworkInfo>(),
          authLocal: getIt<AuthLocalDataSource>(),
        ),
      )
      ..registerFactory<ProfileCubit>(
        () => ProfileCubit(getIt<ProfileRepository>()),
      );
  }
}
