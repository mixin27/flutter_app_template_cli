import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import 'router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.read<AppConfig>();
    final authCubit = context.read<AuthCubit>();
    final router = AppRouter(authCubit: authCubit).router;

    return MaterialApp.router(
      title: config.appName,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
