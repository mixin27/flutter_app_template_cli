import 'dart:io';

import 'package:flutter_app_template_cli/flutter_app_template_cli.dart' as cli;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('prints version from pubspec', () async {
    final out = StringBuffer();
    final err = StringBuffer();

    final code = await cli.run(['--version'], out: out, err: err);

    expect(code, 0);
    expect(
      out.toString().trim(),
      'flutter_app_template_cli ${_readVersionSync()}',
    );
    expect(err.toString(), isEmpty);
  });

  test('prints help output', () async {
    final out = StringBuffer();
    final err = StringBuffer();

    final code = await cli.run(['--help'], out: out, err: err);

    expect(code, 0);
    expect(out.toString(), contains('Available commands:'));
    expect(err.toString(), isEmpty);
  });

  test('errors when workspace name is missing', () async {
    final out = StringBuffer();
    final err = StringBuffer();

    final code = await cli.run(['create'], out: out, err: err);

    expect(code, 64);
    expect(err.toString(), contains('Missing workspace name.'));
    expect(out.toString(), contains('create <workspace_name>'));
  });

  test('errors when workspace name is invalid', () async {
    final out = StringBuffer();
    final err = StringBuffer();

    final code = await cli.run(['create', 'BadName'], out: out, err: err);

    expect(code, 64);
    expect(err.toString(), contains('Invalid workspace name'));
  });

  test('errors when monorepo app name matches workspace name', () async {
    final out = StringBuffer();
    final err = StringBuffer();

    final code = await cli.run(
      [
        'create',
        'demo_workspace',
        '--template',
        'monorepo',
        '--app-name',
        'demo_workspace',
      ],
      out: out,
      err: err,
    );

    expect(code, 64);
    expect(
      err.toString(),
      contains('App name must differ from workspace name'),
    );
  });

  test('template list shows built-ins', () async {
    final out = StringBuffer();
    final err = StringBuffer();

    final code = await cli.run(['template', 'list'], out: out, err: err);

    expect(code, 0);
    expect(out.toString(), contains('monorepo'));
    expect(err.toString(), isEmpty);
  });

  test('creates workspace from a local template', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'flutter_app_template_cli_local_',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final templateDir = Directory(p.join(tempDir.path, 'template'));
    await templateDir.create(recursive: true);
    await File(p.join(templateDir.path, 'template.yaml')).writeAsString('''
name: local
description: Local template
variables:
  custom:
    description: Custom value
    default: default-value
''');
    await File(p.join(templateDir.path, 'README.md')).writeAsString(
      '# __WORKSPACE_NAME__\nCustom: {{custom}}\n',
    );
    final tokenDir = Directory(
      p.join(templateDir.path, 'config', '__APP_NAME__'),
    );
    await tokenDir.create(recursive: true);
    await File(p.join(tokenDir.path, 'settings.txt')).writeAsString(
      'name=__APP_NAME__',
    );

    final outputDir = Directory(p.join(tempDir.path, 'output'));
    await outputDir.create(recursive: true);

    final out = StringBuffer();
    final err = StringBuffer();

    final code = await cli.run(
      [
        'create',
        'local_workspace',
        '--template',
        templateDir.path,
        '--output',
        outputDir.path,
        '--var',
        'custom=overridden',
      ],
      out: out,
      err: err,
    );

    expect(code, 0, reason: err.toString());
    final workspaceDir = Directory(p.join(outputDir.path, 'local_workspace'));
    expect(workspaceDir.existsSync(), isTrue);
    expect(
      File(p.join(workspaceDir.path, 'template.yaml')).existsSync(),
      isFalse,
    );

    final readme = File(p.join(workspaceDir.path, 'README.md'));
    expect(readme.existsSync(), isTrue);
    final content = await readme.readAsString();
    expect(content, contains('# local_workspace'));
    expect(content, contains('Custom: overridden'));

    final settingsFile = File(
      p.join(workspaceDir.path, 'config', 'local_workspace', 'settings.txt'),
    );
    expect(settingsFile.existsSync(), isTrue);
    final settingsContent = await settingsFile.readAsString();
    expect(settingsContent, contains('name=local_workspace'));
  });

  final integrationEnabled =
      Platform.environment['RUN_INTEGRATION_TESTS'] == '1';

  test(
    'creates a workspace (integration)',
    () async {
      if (!await _commandExists('flutter') ||
          !await _commandExists('git')) {
        fail('flutter and git are required to run this integration test.');
      }

      final tempDir = await Directory.systemTemp.createTemp(
        'flutter_app_template_cli_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      const workspaceName = 'demo_workspace';
      const appName = 'demo_app';
      final out = StringBuffer();
      final err = StringBuffer();

      final code = await cli.run(
        [
          'create',
          workspaceName,
          '--app-name',
          appName,
          '--output',
          tempDir.path,
          '--skip-setup',
        ],
        out: out,
        err: err,
      );

      expect(code, 0, reason: err.toString());

      final workspaceDir = Directory(p.join(tempDir.path, workspaceName));
      expect(workspaceDir.existsSync(), isTrue);
      expect(
        Directory(p.join(workspaceDir.path, 'apps', appName)).existsSync(),
        isTrue,
      );
      expect(
        Directory(p.join(workspaceDir.path, 'packages')).existsSync(),
        isTrue,
      );
      expect(Directory(p.join(workspaceDir.path, 'docs')).existsSync(), isTrue);
      expect(
        Directory(p.join(workspaceDir.path, 'scripts')).existsSync(),
        isTrue,
      );
      expect(File(p.join(workspaceDir.path, 'Makefile')).existsSync(), isTrue);
      expect(
        File(p.join(workspaceDir.path, 'pubspec.yaml')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(workspaceDir.path, '.gitignore')).existsSync(),
        isTrue,
      );
      expect(
        Directory(p.join(workspaceDir.path, 'env_examples')).existsSync(),
        isFalse,
      );
      expect(
        Directory(p.join(workspaceDir.path, 'husky_hooks')).existsSync(),
        isFalse,
      );
      expect(
        Directory(p.join(workspaceDir.path, 'app_template')).existsSync(),
        isFalse,
      );
      expect(
        File(p.join(workspaceDir.path, '.env.development.example')).existsSync(),
        isTrue,
      );

      final readme = File(p.join(workspaceDir.path, 'README.md'));
      expect(readme.existsSync(), isTrue);
      final readmeContent = await readme.readAsString();
      expect(readmeContent, contains('# $workspaceName'));
      expect(readmeContent, contains('apps/'));
      expect(readmeContent, contains(appName));
    },
    timeout: Timeout(Duration(minutes: 5)),
    skip: integrationEnabled ? null : 'Set RUN_INTEGRATION_TESTS=1 to run.',
  );
}

String _readVersionSync() {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    return 'unknown';
  }

  final lines = pubspec.readAsLinesSync();
  for (final line in lines) {
    final match = RegExp(r'^version:\s*([^\s#]+)').firstMatch(line.trim());
    if (match != null) {
      return match.group(1) ?? 'unknown';
    }
  }

  return 'unknown';
}

Future<bool> _commandExists(String command) async {
  final result = await Process.run(
    Platform.isWindows ? 'where' : 'command',
    Platform.isWindows ? [command] : ['-v', command],
    runInShell: true,
  );

  return result.exitCode == 0;
}
