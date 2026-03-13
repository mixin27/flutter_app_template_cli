import 'dart:io';

import 'package:flutter_app_template_cli/flutter_app_template_cli.dart' as cli;

Future<void> main(List<String> arguments) async {
  exitCode = await cli.run(arguments);
}
