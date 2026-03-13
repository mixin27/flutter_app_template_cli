import 'package:app_logger/app_logger.dart';
import 'package:app_network/app_network.dart';
import 'package:get_it/get_it.dart';

import '../../../app/di/modules/dependency_module.dart';
import '../../../app/di/modules/get_it_extensions.dart';
import '../data/datasources/profile_local_data_source.dart';
import '../data/datasources/profile_remote_data_source.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/get_profile_use_case.dart';
import '../presentation/bloc/profile_bloc.dart';

class ProfileModule implements DependencyModule {
  const ProfileModule();

  @override
  void register(GetIt getIt) {
    getIt
      ..putLazySingletonIfAbsent<ProfileLocalDataSource>(
        () => ProfileLocalDataSourceImpl(),
      )
      ..putLazySingletonIfAbsent<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(getIt<ApiClient>()),
      )
      ..putLazySingletonIfAbsent<ProfileRepository>(
        () => ProfileRepositoryImpl(
          getIt<ProfileLocalDataSource>(),
          getIt<ProfileRemoteDataSource>(),
          logger: getIt<AppLogger>(),
        ),
      )
      ..putLazySingletonIfAbsent<GetProfileUseCase>(
        () => GetProfileUseCase(getIt<ProfileRepository>()),
      )
      ..putFactoryIfAbsent<ProfileBloc>(
        () => ProfileBloc(
          getIt<GetProfileUseCase>(),
          logger: getIt<AppLogger>(),
        ),
      );
  }
}
