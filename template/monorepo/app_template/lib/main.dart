import 'package:flutter/foundation.dart';

import 'app/app.dart';
import 'app/bootstrap/bootstrap.dart';
import 'app/config/app_environment.dart';

Future<void> main() async {
  await bootstrap(
    () => const App(),
    environmentOverride: kReleaseMode
        ? AppEnvironment.production
        : AppEnvironment.development,
  );
}
