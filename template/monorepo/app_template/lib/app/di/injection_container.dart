import 'package:app_logger/app_logger.dart';
import 'package:app_storage/app_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/di/auth_module.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/di/home_module.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/di/profile_module.dart';
import '../../features/tasks/data/datasources/task_local_data_source.dart';
import '../../features/tasks/di/tasks_module.dart';
import '../config/app_config.dart';
import '../router/app_router.dart';
import 'modules/app_core_module.dart';
import 'modules/dependency_module.dart';
import 'modules/network_module.dart';
import 'modules/router_module.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies({
  required AppConfig appConfig,
  required AppLogger appLogger,
}) async {
  if (getIt.isRegistered<AppRouter>()) {
    return;
  }

  final sharedPreferencesService = await SharedPreferencesService.create();

  final modules = <DependencyModule>[
    AppCoreModule(
      appConfig: appConfig,
      appLogger: appLogger,
      sharedPreferencesService: sharedPreferencesService,
    ),
    const NetworkModule(),
    const AuthModule(),
    const HomeModule(),
    const TasksModule(),
    const ProfileModule(),
    const RouterModule(),
  ];

  for (final module in modules) {
    await module.register(getIt);
  }

  getIt<AuthBloc>().add(const AppStarted());
}

Future<void> seedLocalSampleData() async {
  if (!getIt.isRegistered<AppConfig>()) {
    return;
  }

  final appConfig = getIt<AppConfig>();
  if (!appConfig.enableSampleSeedData) {
    return;
  }

  await getIt<HomeLocalDataSource>().seedSampleDataIfEmpty();
  await getIt<TaskLocalDataSource>().seedSampleDataIfEmpty();
  await getIt<ProfileLocalDataSource>().seedSampleDataIfEmpty();
}
