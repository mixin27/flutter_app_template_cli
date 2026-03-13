import 'app/app.dart';
import 'app/bootstrap/bootstrap.dart';
import 'app/config/app_environment.dart';

Future<void> main() async {
  await bootstrap(
    () => const App(),
    environmentOverride: AppEnvironment.production,
  );
}
