import 'package:flutter/material.dart';

import 'app/app_root.dart';
import 'core/config/app_config.dart';
import 'di/app_injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  await AppInjector.init(config);
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  @override
  void dispose() {
    AppInjector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const AppRoot();
  }
}
