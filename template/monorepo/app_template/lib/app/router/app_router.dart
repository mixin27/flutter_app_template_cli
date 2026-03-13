import 'dart:async';

import 'package:app_logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/phone_otp_challenge.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/auth_entry_page.dart';
import '../../features/auth/presentation/pages/email_login_page.dart';
import '../../features/auth/presentation/pages/otp_verify_page.dart';
import '../../features/auth/presentation/pages/phone_auth_page.dart';
import '../../features/devtools/presentation/pages/logs_devtools_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/presentation/pages/task_detail_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../auth/access/auth_access_strategy.dart';
import '../auth/access/auth_feature_registry.dart';
import 'app_route_paths.dart';

class AppRouter {
  AppRouter({
    required AuthBloc authBloc,
    required AuthAccessStrategy authAccessStrategy,
    required AuthFeatureRegistry authFeatureRegistry,
    required AppLogger appLogger,
    required bool enableLogDevTools,
  })  : _authBloc = authBloc,
        _authAccessStrategy = authAccessStrategy,
        _authFeatureRegistry = authFeatureRegistry,
        _appLogger = appLogger,
        _enableLogDevTools = enableLogDevTools,
        _refreshNotifier = _RouterRefreshNotifier(authBloc.stream);

  static const homePath = AppRoutePaths.home;
  static const tasksPath = AppRoutePaths.tasks;
  static const profilePath = AppRoutePaths.profile;
  static const authPath = AppRoutePaths.auth;
  static const authPhonePath = AppRoutePaths.authPhone;
  static const authEmailPath = AppRoutePaths.authEmail;
  static const authOtpPath = AppRoutePaths.authOtp;
  static const devtoolsLogsPath = AppRoutePaths.devtoolsLogs;

  final AuthBloc _authBloc;
  final AuthAccessStrategy _authAccessStrategy;
  final AuthFeatureRegistry _authFeatureRegistry;
  final AppLogger _appLogger;
  final bool _enableLogDevTools;
  final _RouterRefreshNotifier _refreshNotifier;

  late final GoRouter _router = GoRouter(
    initialLocation: homePath,
    refreshListenable: _refreshNotifier,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: authPath,
        builder: (context, state) {
          return AuthEntryPage(from: _readFrom(state.uri));
        },
        routes: [
          GoRoute(
            path: 'phone',
            builder: (context, state) {
              return PhoneAuthPage(from: _readFrom(state.uri));
            },
          ),
          GoRoute(
            path: 'email',
            builder: (context, state) {
              return EmailLoginPage(from: _readFrom(state.uri));
            },
          ),
          GoRoute(
            path: 'otp',
            builder: (context, state) {
              final phoneNumber = state.uri.queryParameters['phone'];
              if (phoneNumber == null || phoneNumber.isEmpty) {
                return const _DetailUnavailablePage(
                  title: 'Missing phone number for OTP verification',
                );
              }

              return OtpVerifyPage(
                phoneNumber: phoneNumber,
                purpose: _readOtpPurpose(state.uri.queryParameters['purpose']),
                challengeId: state.uri.queryParameters['challengeId'],
                from: _readFrom(state.uri),
              );
            },
          ),
        ],
      ),
      if (_enableLogDevTools)
        GoRoute(
          path: devtoolsLogsPath,
          builder: (context, state) {
            return LogsDevtoolsPage(logger: _appLogger);
          },
        ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: homePath,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: tasksPath,
                builder: (context, state) => const TasksPage(),
                routes: [
                  GoRoute(
                    path: ':taskId',
                    builder: (context, state) {
                      final task = state.extra;
                      if (task is! Task) {
                        return const _DetailUnavailablePage(
                          title: 'Task detail unavailable',
                        );
                      }

                      return TaskDetailPage(task: task);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profilePath,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  GoRouter get config => _router;

  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = _authBloc.state;
    final isAuthResolved =
        authState.status != AuthStatus.unknown &&
            authState.status != AuthStatus.checking;
    if (!isAuthResolved) {
      return null;
    }

    final path = state.uri.path;
    if (!_enableLogDevTools && path == devtoolsLogsPath) {
      return homePath;
    }

    final isAuthenticated =
        authState.status == AuthStatus.authenticated &&
            (authState.session?.isAuthenticated ?? false);
    final isAuthPath = _isAuthPath(path);
    final requiresAuthentication = _authAccessStrategy
        .requiresAuthenticationForPath(path, _authFeatureRegistry);

    if (!isAuthenticated && requiresAuthentication && !isAuthPath) {
      return _authRedirectPath(from: state.uri.toString());
    }

    if (isAuthenticated && isAuthPath) {
      final from = _readFrom(state.uri);
      if (from != null && from.isNotEmpty) {
        try {
          final fromPath = Uri.parse(from).path;
          if (!_isAuthPath(fromPath)) {
            return from;
          }
        } catch (_) {
          return homePath;
        }
      }

      return homePath;
    }

    return null;
  }

  bool _isAuthPath(String path) {
    return path == authPath || path.startsWith('$authPath/');
  }

  String _authRedirectPath({required String from}) {
    return Uri(
      path: authPath,
      queryParameters: <String, String>{'from': from},
    ).toString();
  }

  String? _readFrom(Uri uri) {
    final from = uri.queryParameters['from'];
    if (from == null || from.isEmpty) {
      return null;
    }

    return from;
  }

  PhoneOtpPurpose _readOtpPurpose(String? rawValue) {
    if (rawValue == PhoneOtpPurpose.registration.value) {
      return PhoneOtpPurpose.registration;
    }

    return PhoneOtpPurpose.login;
  }
}

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleForIndex(navigationShell.currentIndex))),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Tasks';
      case 2:
        return 'Profile';
      default:
        return '__APP_NAME__';
    }
  }
}

class _DetailUnavailablePage extends StatelessWidget {
  const _DetailUnavailablePage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unavailable')),
      body: Center(child: Text(title)),
    );
  }
}

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
