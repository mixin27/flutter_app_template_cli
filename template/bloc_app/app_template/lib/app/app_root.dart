import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di/app_injector.dart';
import '../core/config/app_config.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/profile/presentation/bloc/profile_cubit.dart';
import '../features/tasks/presentation/bloc/tasks_cubit.dart';
import 'app.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppConfig>.value(value: getIt<AppConfig>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<AuthCubit>()..initialize()),
          BlocProvider(create: (_) => getIt<TasksCubit>()..initialize()),
          BlocProvider(create: (_) => getIt<ProfileCubit>()),
        ],
        child: const App(),
      ),
    );
  }
}
