import 'package:get_it/get_it.dart';

import '../core/config/app_config.dart';
import '../data/database/app_database.dart';
import 'modules/auth_module.dart';
import 'modules/core_module.dart';
import 'modules/profile_module.dart';
import 'modules/tasks_module.dart';

final GetIt getIt = GetIt.instance;

class AppInjector {
  static Future<void> init(AppConfig config) async {
    if (!getIt.isRegistered<AppConfig>()) {
      getIt.registerSingleton<AppConfig>(config);
    }

    CoreModule().register(getIt);
    AuthModule().register(getIt);
    ProfileModule().register(getIt);
    TasksModule().register(getIt);
  }

  static Future<void> dispose() async {
    if (getIt.isRegistered<AppDatabase>()) {
      await getIt<AppDatabase>().close();
    }
    await getIt.reset();
  }
}
