import 'package:get_it/get_it.dart';

import '../../data/database/app_database.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/presentation/bloc/tasks_cubit.dart';

class TasksModule {
  void register(GetIt getIt) {
    getIt
      ..registerLazySingleton<TaskRepository>(
        () => TaskRepositoryImpl(getIt<TasksDao>()),
      )
      ..registerFactory<TasksCubit>(() => TasksCubit(getIt<TaskRepository>()));
  }
}
