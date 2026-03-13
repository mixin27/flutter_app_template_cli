import 'package:flutter_app_template_cli/flutter_app_template_cli.dart' as cli;

Future<void> main() async {
  final exitCode = await cli.run([
    'create',
    'demo_workspace',
    '--template',
    'monorepo',
    '--skip-setup',
  ]);

  print('Exit code: $exitCode');
}
