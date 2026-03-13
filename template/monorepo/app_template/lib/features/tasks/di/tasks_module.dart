import 'package:app_logger/app_logger.dart';
import 'package:app_network/app_network.dart';
import 'package:get_it/get_it.dart';

import '../../../app/di/modules/dependency_module.dart';
import '../../../app/di/modules/get_it_extensions.dart';
import '../data/datasources/task_local_data_source.dart';
import '../data/datasources/task_remote_data_source.dart';
import '../data/repositories/task_repository_impl.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/usecases/get_tasks_use_case.dart';
import '../domain/usecases/toggle_task_use_case.dart';
import '../presentation/bloc/tasks_bloc.dart';

class TasksModule implements DependencyModule {
  const TasksModule();

  @override
  void register(GetIt getIt) {
    getIt
      ..putLazySingletonIfAbsent<TaskLocalDataSource>(
        () => TaskLocalDataSourceImpl(),
      )
      ..putLazySingletonIfAbsent<TaskRemoteDataSource>(
        () => TaskRemoteDataSourceImpl(getIt<ApiClient>()),
      )
      ..putLazySingletonIfAbsent<TaskRepository>(
        () => TaskRepositoryImpl(
          getIt<TaskLocalDataSource>(),
          getIt<TaskRemoteDataSource>(),
          logger: getIt<AppLogger>(),
        ),
      )
      ..putLazySingletonIfAbsent<GetTasksUseCase>(
        () => GetTasksUseCase(getIt<TaskRepository>()),
      )
      ..putLazySingletonIfAbsent<ToggleTaskUseCase>(
        () => ToggleTaskUseCase(getIt<TaskRepository>()),
      )
      ..putFactoryIfAbsent<TasksBloc>(
        () => TasksBloc(
          getIt<GetTasksUseCase>(),
          getIt<ToggleTaskUseCase>(),
          logger: getIt<AppLogger>(),
        ),
      );
  }
}
