import 'dart:io';
import 'dart:isolate';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

Future<int> run(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.')
    ..addFlag('version', negatable: false, help: 'Show version.');

  final createParser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.')
    ..addOption(
      'app-name',
      abbr: 'a',
      help: 'Flutter app package name (snake_case).',
    )
    ..addOption(
      'org',
      abbr: 'o',
      defaultsTo: 'com.example',
      help: 'Organization identifier for flutter create.',
    )
    ..addOption(
      'description',
      abbr: 'd',
      defaultsTo: 'A new Flutter app.',
      help: 'App description used in pubspec.yaml.',
    )
    ..addOption(
      'output',
      abbr: 't',
      defaultsTo: '.',
      help: 'Output directory for the workspace.',
    );

  parser.addCommand('create', createParser);

  late ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (error) {
    _stderr('Error: $error');
    _printUsage(parser);
    return _ExitCodes.usage;
  }

  if (results['version'] == true) {
    _stdout('flutter_app_template_cli 0.1.0');
    return _ExitCodes.success;
  }

  if (results['help'] == true || results.command == null) {
    _printUsage(parser);
    return _ExitCodes.success;
  }

  final command = results.command!;
  if (command.name != 'create') {
    _stderr('Unknown command: ${command.name}');
    _printUsage(parser);
    return _ExitCodes.usage;
  }

  if (command['help'] == true) {
    _printCreateUsage(parser, createParser);
    return _ExitCodes.success;
  }

  if (command.rest.isEmpty) {
    _stderr('Missing workspace name.');
    _printCreateUsage(parser, createParser);
    return _ExitCodes.usage;
  }

  final workspaceName = command.rest.first;
  final appName = (command['app-name'] as String?)?.trim().isNotEmpty == true
      ? (command['app-name'] as String).trim()
      : workspaceName;
  final org = (command['org'] as String).trim();
  final description = (command['description'] as String).trim();
  final outputDir = Directory(command['output'] as String).absolute;

  if (!_isValidPackageName(workspaceName)) {
    _stderr('Invalid workspace name: $workspaceName');
    _stderr('Use lowercase letters, numbers, and underscores only.');
    return _ExitCodes.usage;
  }

  if (!_isValidPackageName(appName)) {
    _stderr('Invalid app name: $appName');
    _stderr('Use lowercase letters, numbers, and underscores only.');
    return _ExitCodes.usage;
  }

  final generator = TemplateGenerator(await _resolveTemplateRoot());
  try {
    await generator.createWorkspace(
      workspaceName: workspaceName,
      appName: appName,
      org: org,
      description: description,
      outputDir: outputDir,
    );
  } catch (error) {
    _stderr('Failed to create workspace: $error');
    return _ExitCodes.software;
  }

  _stdout('Workspace created at ${p.join(outputDir.path, workspaceName)}');
  return _ExitCodes.success;
}

Future<String> _resolveTemplateRoot() async {
  final packageUri = await Isolate.resolvePackageUri(
    Uri.parse('package:flutter_app_template_cli/flutter_app_template_cli.dart'),
  );
  if (packageUri != null) {
    final libPath = File.fromUri(packageUri).path;
    return p.normalize(p.join(p.dirname(libPath), '..'));
  }

  final scriptPath = File.fromUri(Platform.script).path;
  var candidateDir = Directory(p.dirname(scriptPath));
  for (var depth = 0; depth < 6; depth++) {
    final templateDir = Directory(
      p.join(candidateDir.path, 'template', 'monorepo'),
    );
    if (templateDir.existsSync()) {
      return candidateDir.path;
    }
    candidateDir = candidateDir.parent;
  }

  return p.normalize(p.join(p.dirname(scriptPath), '..'));
}

bool _isValidPackageName(String value) {
  return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value);
}

void _printUsage(ArgParser parser) {
  _stdout('flutter_app_template_cli <command> [arguments]');
  _stdout('');
  _stdout('Available commands:');
  _stdout('  create <workspace_name>    Generate a new monorepo workspace');
  _stdout('');
  _stdout('Options:');
  _stdout(parser.usage);
}

void _printCreateUsage(ArgParser root, ArgParser createParser) {
  _stdout('flutter_app_template_cli create <workspace_name> [options]');
  _stdout('');
  _stdout('Options:');
  _stdout(createParser.usage);
  _stdout('');
  _stdout('Global options:');
  _stdout(root.usage);
}

void _stdout(String message) => stdout.writeln(message);

void _stderr(String message) => stderr.writeln(message);

class _ExitCodes {
  const _ExitCodes._();

  static const int success = 0;
  static const int usage = 64;
  static const int software = 70;
}

class TemplateGenerator {
  TemplateGenerator(this._packageRoot);

  final String _packageRoot;

  Future<void> createWorkspace({
    required String workspaceName,
    required String appName,
    required String org,
    required String description,
    required Directory outputDir,
  }) async {
    final workspaceDir = Directory(p.join(outputDir.path, workspaceName));
    if (workspaceDir.existsSync()) {
      throw 'Target directory already exists: ${workspaceDir.path}';
    }

    final templateDir = Directory(p.join(_packageRoot, 'template', 'monorepo'));
    if (!templateDir.existsSync()) {
      throw 'Template directory not found: ${templateDir.path}';
    }

    await _copyDirectory(templateDir, workspaceDir);

    final appDir = Directory(p.join(workspaceDir.path, 'apps', appName));
    await _runFlutterCreate(
      appDir: appDir,
      appName: appName,
      org: org,
      description: description,
    );

    final appTemplateDir = Directory(p.join(workspaceDir.path, 'app_template'));
    if (!appTemplateDir.existsSync()) {
      throw 'Missing app_template in workspace.';
    }

    await _copyDirectory(appTemplateDir, appDir, overwrite: true);
    await appTemplateDir.delete(recursive: true);

    await _replaceTokensInDirectory(workspaceDir, {
      '__WORKSPACE_NAME__': workspaceName,
      '__APP_NAME__': appName,
    });

    await _ensureScriptsExecutable(workspaceDir);
  }

  Future<void> _runFlutterCreate({
    required Directory appDir,
    required String appName,
    required String org,
    required String description,
  }) async {
    final args = <String>[
      'create',
      '--org',
      org,
      '--project-name',
      appName,
      '--description',
      description,
      appDir.path,
    ];

    final process = await Process.start(
      'flutter',
      args,
      runInShell: true,
    );

    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw 'flutter create failed with exit code $exitCode';
    }
  }

  Future<void> _copyDirectory(
    Directory source,
    Directory destination, {
    bool overwrite = true,
  }) async {
    if (!destination.existsSync()) {
      await destination.create(recursive: true);
    }

    await for (final entity in source.list(followLinks: false)) {
      final newPath = p.join(destination.path, p.basename(entity.path));
      if (entity is File) {
        final target = File(newPath);
        if (target.existsSync() && !overwrite) {
          continue;
        }
        await target.parent.create(recursive: true);
        await entity.copy(newPath);
      } else if (entity is Directory) {
        await _copyDirectory(Directory(entity.path), Directory(newPath));
      }
    }
  }

  Future<void> _replaceTokensInDirectory(
    Directory root,
    Map<String, String> replacements,
  ) async {
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }

      final extension = p.extension(entity.path).toLowerCase();
      if (!_isTextExtension(extension)) {
        continue;
      }

      final content = await entity.readAsString();
      var updated = content;
      replacements.forEach((key, value) {
        updated = updated.replaceAll(key, value);
      });

      if (updated != content) {
        await entity.writeAsString(updated);
      }
    }
  }

  bool _isTextExtension(String extension) {
    const textExtensions = {
      '.dart',
      '.yaml',
      '.yml',
      '.md',
      '.txt',
      '.json',
      '.xml',
      '.gradle',
      '.properties',
      '.xcconfig',
      '.sh',
    };

    return textExtensions.contains(extension);
  }

  Future<void> _ensureScriptsExecutable(Directory workspaceDir) async {
    if (Platform.isWindows) {
      return;
    }

    final scriptsDir = Directory(p.join(workspaceDir.path, 'scripts'));
    if (!scriptsDir.existsSync()) {
      return;
    }

    final scripts = [
      p.join(scriptsDir.path, 'pub_get_all.sh'),
      p.join(scriptsDir.path, 'analyze_all.sh'),
      p.join(scriptsDir.path, 'test_all.sh'),
      p.join(scriptsDir.path, 'format_all.sh'),
      p.join(scriptsDir.path, 'codegen_all.sh'),
      p.join(scriptsDir.path, 'clean_all.sh'),
      p.join(scriptsDir.path, 'install_git_hooks.sh'),
      p.join(workspaceDir.path, '.husky', 'commit-msg'),
      p.join(workspaceDir.path, '.husky', 'pre-push'),
    ];

    for (final script in scripts) {
      if (File(script).existsSync()) {
        await Process.run('chmod', ['+x', script]);
      }
    }
  }
}
