import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'config/app_config.dart';
import 'config/app_environment.dart';
import 'di/injection_container.dart';
import 'router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  static const String _appName = '__APP_NAME__';

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    final appConfig = getIt<AppConfig>();

    return BlocProvider<AuthBloc>.value(
      value: getIt<AuthBloc>(),
      child: MaterialApp.router(
        title: _buildAppTitle(appConfig.environment),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter.config,
      ),
    );
  }

  String _buildAppTitle(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.development:
        return '$_appName (Dev)';
      case AppEnvironment.staging:
        return '$_appName (Staging)';
      case AppEnvironment.production:
        return _appName;
    }
  }
}
