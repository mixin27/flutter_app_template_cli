import 'dart:async';

import 'package:app_logger/app_logger.dart';
import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../config/app_config.dart';
import '../config/app_environment.dart';
import '../di/injection_container.dart';
import 'startup_logger.dart';
import 'startup_runner.dart';
import 'startup_task.dart';

/// Bootstraps the application.
///
/// Why we use a dedicated bootstrap:
/// - Centralizes environment config, DI wiring, and error hooks.
/// - Keeps `main.dart` minimal and consistent across flavors.
/// - Ensures critical startup tasks finish before rendering the app.
Future<void> bootstrap(
  /// Widget builder for the root of the app.
  ///
  /// This is invoked after critical startup tasks finish so the app tree
  /// sees fully initialized dependencies.
  FutureOr<Widget> Function() builder, {
  AppEnvironment? environmentOverride,
}) async {
  final appConfig = AppConfig.fromEnvironment(
    environmentOverride: environmentOverride,
  );
  final appLogger = AppLogger();
  final logger = StartupLogger(
    enabled: appConfig.enableVerboseStartupLogs,
    logger: appLogger,
  );

  // runZonedGuarded catches uncaught async errors during startup and after
  // runApp, giving us a single place to log and surface fatal issues.
  await runZonedGuarded(
    () async {
      // Ensure Flutter bindings are available before any plugins are used.
      WidgetsFlutterBinding.ensureInitialized();

      // Hook into framework/platform errors early so we don't lose crash details.
      _configureFrameworkErrorHooks(logger);
      // Register font licenses so they appear in the "Licenses" screen.
      AppFontLicenses.register();

      final startupRunner = StartupRunner(logger);
      final startupTasks = _buildStartupTasks(appConfig, appLogger);

      // Critical tasks must complete before the UI is rendered.
      await startupRunner.runCritical(startupTasks);

      // Render the UI once core services are ready.
      runApp(await builder());
      // Deferred tasks run in the background and should not block first frame.
      unawaited(startupRunner.runDeferred(startupTasks));
    },
    (error, stackTrace) {
      logger.error('Unhandled zone error', error, stackTrace);

      if (!kReleaseMode) {
        FlutterError.presentError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            context: ErrorDescription('Unhandled error in app bootstrap zone'),
          ),
        );
      }
    },
  );
}

/// Build the list of startup tasks for the current environment.
///
/// This keeps task definitions centralized so it's easy to see what happens
/// before the first frame vs. what can be deferred.
List<StartupTask> _buildStartupTasks(AppConfig config, AppLogger appLogger) {
  return <StartupTask>[
    StartupTask(
      name: 'configure_dependencies',
      operation: () =>
          configureDependencies(appConfig: config, appLogger: appLogger),
      isCritical: true,
    ),
    StartupTask(
      name: 'seed_local_sample_data',
      operation: () => seedLocalSampleData(),
      isCritical: config.enableSampleSeedData,
    ),
  ];
}

/// Configure Flutter framework and platform error hooks.
///
/// We do this early so errors during bootstrap and runtime are captured
/// consistently and routed through [StartupLogger].
void _configureFrameworkErrorHooks(StartupLogger logger) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);

    final stackTrace = details.stack ?? StackTrace.current;
    logger.error('Flutter framework error', details.exception, stackTrace);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error('Platform dispatcher error', error, stackTrace);
    return kReleaseMode;
  };
}
