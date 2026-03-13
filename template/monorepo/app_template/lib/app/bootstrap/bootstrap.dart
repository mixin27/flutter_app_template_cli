import 'dart:async';

import 'package:app_logger/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../config/app_config.dart';
import '../config/app_environment.dart';
import '../di/injection_container.dart';
import 'startup_logger.dart';
import 'startup_runner.dart';
import 'startup_task.dart';

Future<void> bootstrap(
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

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      _configureFrameworkErrorHooks(logger);

      final startupRunner = StartupRunner(logger);
      final startupTasks = _buildStartupTasks(appConfig, appLogger);

      await startupRunner.runCritical(startupTasks);

      runApp(await builder());
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
