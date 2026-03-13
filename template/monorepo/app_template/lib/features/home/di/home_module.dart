import 'package:app_logger/app_logger.dart';
import 'package:app_network/app_network.dart';
import 'package:get_it/get_it.dart';

import '../../../app/di/modules/dependency_module.dart';
import '../../../app/di/modules/get_it_extensions.dart';
import '../data/datasources/home_local_data_source.dart';
import '../data/datasources/home_remote_data_source.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/get_home_summary_use_case.dart';
import '../presentation/bloc/home_bloc.dart';

class HomeModule implements DependencyModule {
  const HomeModule();

  @override
  void register(GetIt getIt) {
    getIt
      ..putLazySingletonIfAbsent<HomeLocalDataSource>(
        () => HomeLocalDataSourceImpl(),
      )
      ..putLazySingletonIfAbsent<HomeRemoteDataSource>(
        () => HomeRemoteDataSourceImpl(getIt<ApiClient>()),
      )
      ..putLazySingletonIfAbsent<HomeRepository>(
        () => HomeRepositoryImpl(
          getIt<HomeLocalDataSource>(),
          getIt<HomeRemoteDataSource>(),
          logger: getIt<AppLogger>(),
        ),
      )
      ..putLazySingletonIfAbsent<GetHomeSummaryUseCase>(
        () => GetHomeSummaryUseCase(getIt<HomeRepository>()),
      )
      ..putFactoryIfAbsent<HomeBloc>(
        () => HomeBloc(
          getIt<GetHomeSummaryUseCase>(),
          logger: getIt<AppLogger>(),
        ),
      );
  }
}
