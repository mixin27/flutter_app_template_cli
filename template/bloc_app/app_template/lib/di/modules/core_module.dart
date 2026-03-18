import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../data/database/app_database.dart';

class CoreModule {
  void register(GetIt getIt) {
    getIt
      ..registerLazySingleton<http.Client>(http.Client.new)
      ..registerLazySingleton<NetworkInfo>(
        () => ConnectivityNetworkInfo(Connectivity()),
      )
      ..registerLazySingleton<ApiClient>(
        () => ApiClient(getIt<http.Client>(), getIt<AppConfig>()),
      )
      ..registerLazySingleton<AppDatabase>(AppDatabase.new)
      ..registerLazySingleton<TasksDao>(() => getIt<AppDatabase>().tasksDao)
      ..registerLazySingleton<AuthDao>(() => getIt<AppDatabase>().authDao)
      ..registerLazySingleton<ProfilesDao>(
        () => getIt<AppDatabase>().profilesDao,
      );
  }
}
