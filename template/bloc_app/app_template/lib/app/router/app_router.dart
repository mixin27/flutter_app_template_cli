import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../shell/home_shell.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  AppRouter({required AuthCubit authCubit})
    : _router = GoRouter(
        initialLocation: '/tasks',
        refreshListenable: GoRouterRefreshStream(authCubit.stream),
        redirect: (context, state) {
          final isAuthed = authCubit.state.isAuthenticated;
          final isLoggingIn = state.matchedLocation == '/login';

          if (!isAuthed) {
            return isLoggingIn ? null : '/login';
          }

          if (isLoggingIn) {
            return '/tasks';
          }

          return null;
        },
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginPage(),
          ),
          ShellRoute(
            builder: (context, state, child) => HomeShell(child: child),
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TasksPage(),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      );

  final GoRouter _router;

  GoRouter get router => _router;
}
