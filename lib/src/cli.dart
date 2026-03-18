import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class CliLogger {
  CliLogger({StringSink? out, StringSink? err})
    : _out = out ?? stdout,
      _err = err ?? stderr;

  final StringSink _out;
  final StringSink _err;

  void out(String message) => _out.writeln(message);

  void err(String message) => _err.writeln(message);
}

/// Runs the CLI with the provided arguments.
///
/// Returns a process exit code. Optionally provide [out] and [err] sinks to
/// capture output in tests or other tooling.
Future<int> run(
  List<String> arguments, {
  StringSink? out,
  StringSink? err,
}) async {
  final logger = CliLogger(out: out, err: err);
  final parser = _buildParser();

  late ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (error) {
    logger.err('Error: $error');
    _printUsage(parser, logger);
    return _ExitCodes.usage;
  }

  if (results['version'] == true) {
    final packageRoot = await _resolvePackageRoot();
    final version = await _readVersion(packageRoot);
    logger.out('flutter_app_template_cli $version');
    return _ExitCodes.success;
  }

  if (results['help'] == true || results.command == null) {
    _printUsage(parser, logger);
    return _ExitCodes.success;
  }

  final command = results.command!;
  switch (command.name) {
    case 'create':
      return _handleCreate(command, parser, logger);
    case 'template':
      return _handleTemplate(command, parser, logger);
    default:
      logger.err('Unknown command: ${command.name}');
      _printUsage(parser, logger);
      return _ExitCodes.usage;
  }
}

ArgParser _buildParser() {
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
    )
    ..addOption(
      'template',
      defaultsTo: 'monorepo',
      help: 'Template name, path, or URL.',
    )
    ..addOption(
      'template-ref',
      help: 'Git ref (tag/branch/commit) for template repositories.',
    )
    ..addOption(
      'template-sha256',
      help: 'SHA-256 checksum for template archives.',
    )
    ..addOption(
      'template-path',
      help: 'Subdirectory inside the template source to use.',
    )
    ..addOption(
      'template-type',
      allowed: ['git', 'archive', 'path'],
      help: 'Force template source type.',
    )
    ..addMultiOption(
      'var',
      help: 'Template variable in key=value form. Can be repeated.',
    )
    ..addFlag(
      'skip-setup',
      negatable: false,
      help: 'Skip workspace setup steps (built-ins) or post-generate scripts.',
    )
    ..addFlag(
      'allow-scripts',
      negatable: false,
      help: 'Allow template post-generate scripts to run.',
    );

  parser.addCommand('create', createParser);

  final templateParser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.');

  templateParser.addCommand(
    'list',
    ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );

  final templateAddParser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.')
    ..addOption('ref', help: 'Git ref (tag/branch/commit).')
    ..addOption('sha256', help: 'SHA-256 checksum for template archives.')
    ..addOption('path', help: 'Subdirectory inside the template source to use.')
    ..addOption(
      'type',
      allowed: ['git', 'archive', 'path'],
      help: 'Force template source type.',
    );

  templateParser.addCommand('add', templateAddParser);
  templateParser.addCommand(
    'remove',
    ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );

  parser.addCommand('template', templateParser);

  return parser;
}

Future<int> _handleCreate(
  ArgResults command,
  ArgParser parser,
  CliLogger logger,
) async {
  if (command['help'] == true) {
    _printCreateUsage(parser, logger);
    return _ExitCodes.success;
  }

  if (command.rest.isEmpty) {
    logger.err('Missing workspace name.');
    _printCreateUsage(parser, logger);
    return _ExitCodes.usage;
  }

  final workspaceName = command.rest.first;
  final appNameOption = command['app-name'] as String?;
  final appNameProvided = appNameOption?.trim().isNotEmpty == true;
  var appName = appNameProvided ? appNameOption!.trim() : workspaceName;
  final org = (command['org'] as String).trim();
  final description = (command['description'] as String).trim();
  final outputDir = Directory(command['output'] as String).absolute;
  final templateSelector =
      (command['template'] as String?)?.trim().isNotEmpty == true
      ? (command['template'] as String).trim()
      : 'monorepo';
  final skipSetup = command['skip-setup'] == true;
  final allowScripts = command['allow-scripts'] == true;

  final overrides = TemplateOverrides(
    type: _templateSourceTypeFromString(command['template-type'] as String?),
    ref: command['template-ref'] as String?,
    sha256: command['template-sha256'] as String?,
    path: command['template-path'] as String?,
  );

  Map<String, String> extraVars;
  try {
    extraVars = _parseVariables(command['var'] as List<String>);
  } catch (error) {
    logger.err('Error: $error');
    _printCreateUsage(parser, logger);
    return _ExitCodes.usage;
  }

  final packageRoot = await _resolvePackageRoot();
  final registry = TemplateRegistry(logger);
  final manager = TemplateManager(packageRoot, registry, logger);

  late Template template;
  try {
    template = await manager.resolve(templateSelector, overrides);
  } catch (error) {
    logger.err('Error: $error');
    return _ExitCodes.usage;
  }

  if (template is MonorepoTemplate) {
    if (appName == workspaceName) {
      if (appNameProvided) {
        logger.err(
          'App name must differ from workspace name for the monorepo template.',
        );
        logger.err('Try: --app-name ${workspaceName}_app');
        return _ExitCodes.usage;
      }
      appName = '${workspaceName}_app';
      logger.out('Using default app name "$appName" to avoid name conflicts.');
    }
  }

  if (template.kind == TemplateKind.builtIn) {
    if (!_isValidPackageName(workspaceName)) {
      logger.err('Invalid workspace name: $workspaceName');
      logger.err('Use lowercase letters, numbers, and underscores only.');
      return _ExitCodes.usage;
    }

    if (!_isValidPackageName(appName)) {
      logger.err('Invalid app name: $appName');
      logger.err('Use lowercase letters, numbers, and underscores only.');
      return _ExitCodes.usage;
    }
  } else {
    if (!_isSafeDirectoryName(workspaceName)) {
      logger.err('Invalid workspace name: $workspaceName');
      logger.err('Use a simple directory name without path separators.');
      return _ExitCodes.usage;
    }

    if (!_isSafeDirectoryName(appName)) {
      logger.err('Invalid app name: $appName');
      logger.err('Use a simple directory name without path separators.');
      return _ExitCodes.usage;
    }
  }

  final workspaceDir = Directory(p.join(outputDir.path, workspaceName));
  final variables = _buildVariableContext(
    workspaceName: workspaceName,
    appName: appName,
    org: org,
    description: description,
    extraVars: extraVars,
  );
  final context = TemplateContext(
    workspaceName: workspaceName,
    appName: appName,
    org: org,
    description: description,
    outputDir: outputDir,
    workspaceDir: workspaceDir,
    variables: variables,
    skipSetup: skipSetup,
    allowScripts: allowScripts,
    logger: logger,
  );

  try {
    await template.generate(context);
  } catch (error) {
    logger.err('Failed to create workspace: $error');
    return _ExitCodes.software;
  }

  logger.out('Workspace created at ${workspaceDir.path}');
  return _ExitCodes.success;
}

Future<int> _handleTemplate(
  ArgResults command,
  ArgParser parser,
  CliLogger logger,
) async {
  if (command['help'] == true || command.command == null) {
    _printTemplateUsage(parser, logger);
    return _ExitCodes.success;
  }

  final subcommand = command.command!;
  final packageRoot = await _resolvePackageRoot();
  final registry = TemplateRegistry(logger);
  final manager = TemplateManager(packageRoot, registry, logger);

  switch (subcommand.name) {
    case 'list':
      if (subcommand['help'] == true) {
        _printTemplateListUsage(parser, logger);
        return _ExitCodes.success;
      }
      final builtIns = manager.builtIns();
      final registered = await registry.list();

      logger.out('Built-in templates:');
      if (builtIns.isEmpty) {
        logger.out('  (none)');
      } else {
        for (final template in builtIns) {
          logger.out('  - ${template.name}: ${template.description}');
        }
      }

      logger.out('');
      logger.out('User templates:');
      if (registered.isEmpty) {
        logger.out('  (none)');
      } else {
        for (final template in registered) {
          logger.out(
            '  - ${template.name}: ${_formatTemplateSource(template.source)}',
          );
        }
      }
      return _ExitCodes.success;
    case 'add':
      if (subcommand['help'] == true) {
        _printTemplateAddUsage(parser, logger);
        return _ExitCodes.success;
      }
      if (subcommand.rest.length < 2) {
        logger.err('Missing template name or source.');
        _printTemplateAddUsage(parser, logger);
        return _ExitCodes.usage;
      }

      final name = subcommand.rest[0];
      final source = subcommand.rest[1];
      if (!_isValidTemplateName(name)) {
        logger.err('Invalid template name: $name');
        logger.err('Use lowercase letters, numbers, underscores, and dashes.');
        return _ExitCodes.usage;
      }

      final overrides = TemplateOverrides(
        type: _templateSourceTypeFromString(subcommand['type'] as String?),
        ref: subcommand['ref'] as String?,
        sha256: subcommand['sha256'] as String?,
        path: subcommand['path'] as String?,
      );

      late TemplateSource templateSource;
      try {
        templateSource = TemplateSource.fromValue(source, overrides);
      } catch (error) {
        logger.err('Error: $error');
        return _ExitCodes.usage;
      }

      await registry.add(RegisteredTemplate(name, templateSource));
      logger.out(
        'Registered template $name -> ${_formatTemplateSource(templateSource)}',
      );
      return _ExitCodes.success;
    case 'remove':
      if (subcommand['help'] == true) {
        _printTemplateRemoveUsage(parser, logger);
        return _ExitCodes.success;
      }
      if (subcommand.rest.isEmpty) {
        logger.err('Missing template name.');
        _printTemplateRemoveUsage(parser, logger);
        return _ExitCodes.usage;
      }
      final name = subcommand.rest.first;
      final removed = await registry.remove(name);
      if (!removed) {
        logger.err('No template named $name was found.');
        return _ExitCodes.usage;
      }
      logger.out('Removed template $name.');
      return _ExitCodes.success;
    default:
      logger.err('Unknown template command: ${subcommand.name}');
      _printTemplateUsage(parser, logger);
      return _ExitCodes.usage;
  }
}

Future<String> _resolvePackageRoot() async {
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

Future<String> _readVersion(String packageRoot) async {
  final pubspec = File(p.join(packageRoot, 'pubspec.yaml'));
  if (!await pubspec.exists()) {
    return 'unknown';
  }

  final lines = await pubspec.readAsLines();
  for (final line in lines) {
    final match = RegExp(r'^version:\s*([^\s#]+)').firstMatch(line.trim());
    if (match != null) {
      return match.group(1) ?? 'unknown';
    }
  }

  return 'unknown';
}

bool _isValidPackageName(String value) {
  return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value);
}

bool _isSafeDirectoryName(String value) {
  if (value.trim().isEmpty) {
    return false;
  }
  if (value == '.' || value == '..') {
    return false;
  }
  if (value.contains('/') || value.contains('\\')) {
    return false;
  }
  return true;
}

bool _isValidTemplateName(String value) {
  return RegExp(r'^[a-z][a-z0-9_-]*$').hasMatch(value);
}

Map<String, String> _parseVariables(List<String> rawVars) {
  final variables = <String, String>{};
  for (final entry in rawVars) {
    final index = entry.indexOf('=');
    if (index <= 0) {
      throw 'Invalid --var entry: $entry. Use key=value.';
    }
    final key = entry.substring(0, index).trim();
    final value = entry.substring(index + 1);
    if (key.isEmpty) {
      throw 'Invalid --var entry: $entry. Use key=value.';
    }
    variables[key] = value;
  }
  return variables;
}

Map<String, String> _buildVariableContext({
  required String workspaceName,
  required String appName,
  required String org,
  required String description,
  required Map<String, String> extraVars,
}) {
  final variables = <String, String>{
    'workspace_name': workspaceName,
    'app_name': appName,
    'org': org,
    'description': description,
  };
  variables.addAll(extraVars);
  return variables;
}

void _printUsage(ArgParser parser, CliLogger logger) {
  logger.out('flutter_app_template_cli <command> [arguments]');
  logger.out('');
  logger.out('Available commands:');
  logger.out('  create <workspace_name>    Generate a new workspace');
  logger.out('  template <subcommand>      Manage templates');
  logger.out('');
  logger.out('Options:');
  logger.out(parser.usage);
}

void _printCreateUsage(ArgParser root, CliLogger logger) {
  final createParser = _getCommandParser(root, const ['create']);
  logger.out('flutter_app_template_cli create <workspace_name> [options]');
  logger.out('');
  logger.out('Options:');
  logger.out(createParser?.usage ?? '');
  logger.out('');
  logger.out('Global options:');
  logger.out(root.usage);
}

void _printTemplateUsage(ArgParser root, CliLogger logger) {
  final templateParser = _getCommandParser(root, const ['template']);
  logger.out('flutter_app_template_cli template <subcommand>');
  logger.out('');
  logger.out('Subcommands:');
  logger.out('  list                 List available templates');
  logger.out('  add <name> <source>  Register a template source');
  logger.out('  remove <name>        Remove a registered template');
  logger.out('');
  logger.out('Options:');
  logger.out(templateParser?.usage ?? '');
  logger.out('');
  logger.out('Global options:');
  logger.out(root.usage);
}

void _printTemplateListUsage(ArgParser root, CliLogger logger) {
  final listParser = _getCommandParser(root, const ['template', 'list']);
  logger.out('flutter_app_template_cli template list');
  logger.out('');
  logger.out('Options:');
  logger.out(listParser?.usage ?? '');
  logger.out('');
  logger.out('Global options:');
  logger.out(root.usage);
}

void _printTemplateAddUsage(ArgParser root, CliLogger logger) {
  final addParser = _getCommandParser(root, const ['template', 'add']);
  logger.out('flutter_app_template_cli template add <name> <source>');
  logger.out('');
  logger.out('Options:');
  logger.out(addParser?.usage ?? '');
  logger.out('');
  logger.out('Global options:');
  logger.out(root.usage);
}

void _printTemplateRemoveUsage(ArgParser root, CliLogger logger) {
  final removeParser = _getCommandParser(root, const ['template', 'remove']);
  logger.out('flutter_app_template_cli template remove <name>');
  logger.out('');
  logger.out('Options:');
  logger.out(removeParser?.usage ?? '');
  logger.out('');
  logger.out('Global options:');
  logger.out(root.usage);
}

ArgParser? _getCommandParser(ArgParser root, List<String> path) {
  ArgParser? current = root;
  for (final segment in path) {
    current = current?.commands[segment];
    if (current == null) {
      return null;
    }
  }
  return current;
}

class _ExitCodes {
  const _ExitCodes._();

  static const int success = 0;
  static const int usage = 64;
  static const int software = 70;
}

enum TemplateKind { builtIn, external }

class TemplateContext {
  TemplateContext({
    required this.workspaceName,
    required this.appName,
    required this.org,
    required this.description,
    required this.outputDir,
    required this.workspaceDir,
    required this.variables,
    required this.skipSetup,
    required this.allowScripts,
    required this.logger,
  });

  final String workspaceName;
  final String appName;
  final String org;
  final String description;
  final Directory outputDir;
  final Directory workspaceDir;
  final Map<String, String> variables;
  final bool skipSetup;
  final bool allowScripts;
  final CliLogger logger;
}

abstract class Template {
  String get name;
  String get description;
  TemplateKind get kind;

  Future<void> generate(TemplateContext context);
}

class BuiltInTemplateDescriptor {
  BuiltInTemplateDescriptor({
    required this.name,
    required this.description,
    required this.builder,
  });

  final String name;
  final String description;
  final Template Function() builder;
}

class TemplateManager {
  TemplateManager(this._packageRoot, this._registry, this._logger)
    : _builtIns = {} {
    _builtIns['monorepo'] = BuiltInTemplateDescriptor(
      name: 'monorepo',
      description: 'Flutter monorepo workspace with app template.',
      builder: () => MonorepoTemplate(_packageRoot, logger: _logger),
    );
    _builtIns['bloc_app'] = BuiltInTemplateDescriptor(
      name: 'bloc_app',
      description:
          'Single Flutter app with BLoC, clean architecture, and Drift.',
      builder: () => BlocAppTemplate(_packageRoot),
    );
  }

  final String _packageRoot;
  final TemplateRegistry _registry;
  final CliLogger _logger;
  final Map<String, BuiltInTemplateDescriptor> _builtIns;

  List<BuiltInTemplateDescriptor> builtIns() {
    final templates = _builtIns.values.toList();
    templates.sort((a, b) => a.name.compareTo(b.name));
    return templates;
  }

  Future<Template> resolve(String selector, TemplateOverrides overrides) async {
    final builtIn = _builtIns[selector];
    if (builtIn != null) {
      if (overrides.hasOverrides) {
        throw 'Template overrides are not supported for built-in templates.';
      }
      return builtIn.builder();
    }

    final registered = await _registry.get(selector);
    if (registered != null) {
      return ExternalTemplate(
        registered.source.merge(overrides),
        logger: _logger,
      );
    }

    final source = TemplateSource.fromValue(selector, overrides);
    return ExternalTemplate(source, logger: _logger);
  }
}

class TemplateOverrides {
  TemplateOverrides({this.type, this.ref, this.sha256, this.path});

  final TemplateSourceType? type;
  final String? ref;
  final String? sha256;
  final String? path;

  bool get hasOverrides =>
      type != null || ref != null || sha256 != null || path != null;
}

enum TemplateSourceType { directory, git, archive }

TemplateSourceType? _templateSourceTypeFromString(String? value) {
  switch (value) {
    case 'git':
      return TemplateSourceType.git;
    case 'archive':
      return TemplateSourceType.archive;
    case 'path':
      return TemplateSourceType.directory;
  }
  return null;
}

String _templateSourceTypeToString(TemplateSourceType type) {
  switch (type) {
    case TemplateSourceType.directory:
      return 'path';
    case TemplateSourceType.git:
      return 'git';
    case TemplateSourceType.archive:
      return 'archive';
  }
}

class TemplateSource {
  TemplateSource({
    required this.type,
    required this.source,
    this.ref,
    this.sha256,
    this.path,
  });

  final TemplateSourceType type;
  final String source;
  final String? ref;
  final String? sha256;
  final String? path;

  TemplateSource merge(TemplateOverrides overrides) {
    return TemplateSource(
      type: overrides.type ?? type,
      source: source,
      ref: overrides.ref ?? ref,
      sha256: overrides.sha256 ?? sha256,
      path: overrides.path ?? path,
    );
  }

  static TemplateSource fromValue(String value, TemplateOverrides overrides) {
    final typeOverride = overrides.type;
    if (typeOverride != null) {
      return TemplateSource(
        type: typeOverride,
        source: value,
        ref: overrides.ref,
        sha256: overrides.sha256,
        path: overrides.path,
      );
    }

    final pathType = _detectLocalPathType(value);
    if (pathType != null) {
      return TemplateSource(
        type: pathType,
        source: value,
        ref: overrides.ref,
        sha256: overrides.sha256,
        path: overrides.path,
      );
    }

    if (_looksLikeArchive(value)) {
      return TemplateSource(
        type: TemplateSourceType.archive,
        source: value,
        ref: overrides.ref,
        sha256: overrides.sha256,
        path: overrides.path,
      );
    }

    if (_looksLikeGit(value)) {
      return TemplateSource(
        type: TemplateSourceType.git,
        source: value,
        ref: overrides.ref,
        sha256: overrides.sha256,
        path: overrides.path,
      );
    }

    throw 'Unable to resolve template source: $value';
  }
}

TemplateSourceType? _detectLocalPathType(String value) {
  final entityType = FileSystemEntity.typeSync(value);
  if (entityType == FileSystemEntityType.notFound) {
    return null;
  }
  if (entityType == FileSystemEntityType.directory) {
    return TemplateSourceType.directory;
  }
  if (entityType == FileSystemEntityType.file) {
    return _looksLikeArchive(value) ? TemplateSourceType.archive : null;
  }
  return null;
}

bool _looksLikeArchive(String value) {
  final lower = value.toLowerCase();
  return lower.endsWith('.zip') ||
      lower.endsWith('.tar') ||
      lower.endsWith('.tar.gz') ||
      lower.endsWith('.tgz');
}

bool _looksLikeGit(String value) {
  if (value.startsWith('git@')) {
    return true;
  }
  final uri = Uri.tryParse(value);
  if (uri == null) {
    return false;
  }
  if (uri.hasScheme &&
      (uri.scheme == 'http' ||
          uri.scheme == 'https' ||
          uri.scheme == 'ssh' ||
          uri.scheme == 'git')) {
    return true;
  }
  return false;
}

String _formatTemplateSource(TemplateSource source) {
  final type = _templateSourceTypeToString(source.type);
  final ref = source.ref != null ? ' ref=${source.ref}' : '';
  final path = source.path != null ? ' path=${source.path}' : '';
  return '${source.source} [$type$ref$path]';
}

class TemplateRegistry {
  TemplateRegistry(this._logger);

  final CliLogger _logger;

  Future<List<RegisteredTemplate>> list() async {
    final data = await _load();
    final templates = data.values.toList();
    templates.sort((a, b) => a.name.compareTo(b.name));
    return templates;
  }

  Future<RegisteredTemplate?> get(String name) async {
    final data = await _load();
    return data[name];
  }

  Future<void> add(RegisteredTemplate template) async {
    final data = await _load();
    data[template.name] = template;
    await _save(data);
  }

  Future<bool> remove(String name) async {
    final data = await _load();
    final removed = data.remove(name) != null;
    if (removed) {
      await _save(data);
    }
    return removed;
  }

  Future<Map<String, RegisteredTemplate>> _load() async {
    final file = _registryFile();
    if (!await file.exists()) {
      return {};
    }
    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return {};
    }
    try {
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final templates = decoded['templates'] as Map<String, dynamic>? ?? {};
      final result = <String, RegisteredTemplate>{};
      for (final entry in templates.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          result[entry.key] = RegisteredTemplate.fromJson(entry.key, value);
        }
      }
      return result;
    } catch (error) {
      _logger.err('Failed to read template registry: $error');
      return {};
    }
  }

  Future<void> _save(Map<String, RegisteredTemplate> templates) async {
    final file = _registryFile();
    await file.parent.create(recursive: true);
    final encoded = <String, dynamic>{
      'version': 1,
      'templates': {
        for (final entry in templates.entries) entry.key: entry.value.toJson(),
      },
    };
    final content = const JsonEncoder.withIndent('  ').convert(encoded);
    await file.writeAsString('$content\n');
  }
}

File _registryFile() {
  final configDir = _configDirectory();
  return File(
    p.join(configDir.path, 'flutter_app_template_cli', 'templates.json'),
  );
}

Directory _configDirectory() {
  if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    if (appData != null && appData.isNotEmpty) {
      return Directory(appData);
    }
  } else {
    final xdg = Platform.environment['XDG_CONFIG_HOME'];
    if (xdg != null && xdg.isNotEmpty) {
      return Directory(xdg);
    }
  }
  final home = Platform.environment['HOME'] ?? '.';
  return Directory(p.join(home, '.config'));
}

class RegisteredTemplate {
  RegisteredTemplate(this.name, this.source);

  final String name;
  final TemplateSource source;

  Map<String, dynamic> toJson() {
    return {
      'source': source.source,
      'type': _templateSourceTypeToString(source.type),
      'ref': source.ref,
      'sha256': source.sha256,
      'path': source.path,
    };
  }

  static RegisteredTemplate fromJson(String name, Map<String, dynamic> json) {
    final typeValue = json['type'] as String?;
    final type =
        _templateSourceTypeFromString(typeValue) ??
        TemplateSourceType.directory;
    return RegisteredTemplate(
      name,
      TemplateSource(
        type: type,
        source: json['source'] as String,
        ref: json['ref'] as String?,
        sha256: json['sha256'] as String?,
        path: json['path'] as String?,
      ),
    );
  }
}

class MonorepoTemplate implements Template {
  MonorepoTemplate(this._packageRoot, {CliLogger? logger})
    : _logger = logger ?? CliLogger();

  final String _packageRoot;
  final CliLogger _logger;

  @override
  String get name => 'monorepo';

  @override
  String get description => 'Flutter monorepo workspace with app template.';

  @override
  TemplateKind get kind => TemplateKind.builtIn;

  @override
  Future<void> generate(TemplateContext context) async {
    await _ensureRequiredCommands(skipSetup: context.skipSetup);

    if (context.workspaceDir.existsSync()) {
      throw 'Target directory already exists: ${context.workspaceDir.path}';
    }

    final templateDir = Directory(p.join(_packageRoot, 'template', 'monorepo'));
    if (!templateDir.existsSync()) {
      throw 'Template directory not found: ${templateDir.path}';
    }

    await _copyDirectory(templateDir, context.workspaceDir);
    await _restoreHiddenTemplateEntries(context.workspaceDir);
    await _ensureGitignore(context.workspaceDir);
    await _ensureEnvExampleTemplates(context.workspaceDir);
    await _ensureWorkspaceDirectories(context.workspaceDir);

    final appDir = Directory(
      p.join(context.workspaceDir.path, 'apps', context.appName),
    );
    await _runFlutterCreate(
      appDir: appDir,
      appName: context.appName,
      org: context.org,
      description: context.description,
    );

    final appTemplateDir = Directory(
      p.join(context.workspaceDir.path, 'app_template'),
    );
    if (!appTemplateDir.existsSync()) {
      throw 'Missing app_template in workspace.';
    }

    await _copyDirectory(appTemplateDir, appDir, overwrite: true);
    await appTemplateDir.delete(recursive: true);

    await _replaceTokensInDirectory(context.workspaceDir, {
      '__WORKSPACE_NAME__': context.workspaceName,
      '__APP_NAME__': context.appName,
    });

    await _initializeRepositoryAndHooks(context.workspaceDir, appDir);

    await _ensureScriptsExecutable(context.workspaceDir);

    if (!context.skipSetup) {
      await _runWorkspaceSetup(context.workspaceDir);
    }

    await _cleanupScaffoldDirectories(context.workspaceDir);
  }

  Future<void> _ensureRequiredCommands({required bool skipSetup}) async {
    final requiredCommands = <String>['flutter', 'git'];
    if (!skipSetup) {
      requiredCommands.addAll(['dart', 'make']);
    }

    final missing = <String>[];
    for (final command in requiredCommands) {
      if (!await _commandExists(command)) {
        missing.add(command);
      }
    }

    if (missing.isNotEmpty) {
      throw 'Missing required command(s): ${missing.join(', ')}. '
          'Install them and ensure they are available on your PATH.';
    }
  }

  Future<void> _restoreHiddenTemplateEntries(Directory workspaceDir) async {
    // Pub packages omit hidden entries, so keep template dotfiles under
    // underscore-prefixed names and restore them after copying.
    const hiddenEntries = <String, String>{
      '_github': '.github',
      '_vscode': '.vscode',
      '_husky': '.husky',
      '_gitleaks.toml': '.gitleaks.toml',
    };

    for (final entry in hiddenEntries.entries) {
      final sourcePath = p.join(workspaceDir.path, entry.key);
      final targetPath = p.join(workspaceDir.path, entry.value);

      final sourceDir = Directory(sourcePath);
      if (sourceDir.existsSync()) {
        await _moveDirectory(sourceDir, Directory(targetPath));
        continue;
      }

      final sourceFile = File(sourcePath);
      if (sourceFile.existsSync()) {
        await _moveFile(sourceFile, File(targetPath));
      }
    }
  }

  Future<void> _moveDirectory(Directory source, Directory target) async {
    if (target.existsSync()) {
      await _copyDirectory(source, target, overwrite: false);
      await source.delete(recursive: true);
      return;
    }
    await source.rename(target.path);
  }

  Future<void> _moveFile(File source, File target) async {
    if (target.existsSync()) {
      await source.delete();
      return;
    }
    await target.parent.create(recursive: true);
    await source.rename(target.path);
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

    final process = await Process.start('flutter', args, runInShell: true);

    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw 'flutter create failed with exit code $exitCode';
    }
  }

  Future<void> _ensureGitignore(Directory workspaceDir) async {
    final source = File(p.join(workspaceDir.path, 'gitignore'));
    if (!source.existsSync()) {
      return;
    }

    final target = File(p.join(workspaceDir.path, '.gitignore'));
    if (!target.existsSync()) {
      await source.copy(target.path);
    }

    await source.delete();
  }

  Future<void> _ensureEnvExampleTemplates(Directory workspaceDir) async {
    final envExamplesDir = Directory(p.join(workspaceDir.path, 'env_examples'));
    if (!envExamplesDir.existsSync()) {
      return;
    }

    final envExamplePattern = RegExp(r'^env\.(.+)\.example$');
    await for (final entity in envExamplesDir.list(followLinks: false)) {
      if (entity is! File) {
        continue;
      }

      final fileName = p.basename(entity.path);
      final match = envExamplePattern.firstMatch(fileName);
      if (match == null) {
        continue;
      }

      final envName = match.group(1)!;
      final target = File(p.join(workspaceDir.path, '.env.$envName.example'));
      if (!target.existsSync()) {
        await entity.copy(target.path);
      }
    }
  }

  Future<void> _ensureWorkspaceDirectories(Directory workspaceDir) async {
    final appsDir = Directory(p.join(workspaceDir.path, 'apps'));
    if (!appsDir.existsSync()) {
      await appsDir.create(recursive: true);
    }

    final packagesDir = Directory(p.join(workspaceDir.path, 'packages'));
    if (!packagesDir.existsSync()) {
      await packagesDir.create(recursive: true);
    }
  }

  Future<void> _initializeRepositoryAndHooks(
    Directory workspaceDir,
    Directory appDir,
  ) async {
    final appGitDir = Directory(p.join(appDir.path, '.git'));
    if (appGitDir.existsSync()) {
      await appGitDir.delete(recursive: true);
    }

    final workspaceGitDir = Directory(p.join(workspaceDir.path, '.git'));
    if (!workspaceGitDir.existsSync()) {
      final initResult = await Process.run(
        'git',
        ['init'],
        workingDirectory: workspaceDir.path,
        runInShell: true,
      );

      if (initResult.exitCode != 0) {
        _logger.err('git init failed: ${initResult.stderr}');
        throw 'git init failed with exit code ${initResult.exitCode}';
      }
    }

    await _ensureHuskyHooks(workspaceDir);
  }

  Future<void> _ensureHuskyHooks(Directory workspaceDir) async {
    final hooksDir = Directory(p.join(workspaceDir.path, 'husky_hooks'));
    if (!hooksDir.existsSync()) {
      return;
    }

    final huskyDir = Directory(p.join(workspaceDir.path, '.husky'));
    if (!huskyDir.existsSync()) {
      await huskyDir.create(recursive: true);
    }

    const hookNames = ['commit-msg', 'pre-push'];
    for (final hookName in hookNames) {
      final source = File(p.join(hooksDir.path, hookName));
      if (!source.existsSync()) {
        continue;
      }

      final target = File(p.join(huskyDir.path, hookName));
      if (!target.existsSync()) {
        await source.copy(target.path);
      }
    }
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
      p.join(scriptsDir.path, 'env_init.sh'),
      p.join(scriptsDir.path, 'install_git_hooks.sh'),
      p.join(scriptsDir.path, 'setup_dev.sh'),
      p.join(scriptsDir.path, 'enable_native_flavors.sh'),
      p.join(workspaceDir.path, '.husky', 'commit-msg'),
      p.join(workspaceDir.path, '.husky', 'pre-push'),
    ];

    for (final script in scripts) {
      if (File(script).existsSync()) {
        await Process.run('chmod', ['+x', script]);
      }
    }
  }

  Future<void> _runWorkspaceSetup(Directory workspaceDir) async {
    await _runMake(workspaceDir, ['env-init']);
    await _runMake(workspaceDir, ['setup-dev', 'SKIP_ENV_INIT=1']);
  }

  Future<void> _runMake(Directory workspaceDir, List<String> args) async {
    final process = await Process.start(
      'make',
      args,
      workingDirectory: workspaceDir.path,
      runInShell: true,
    );

    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw 'make ${args.join(' ')} failed with exit code $exitCode';
    }
  }

  Future<void> _cleanupScaffoldDirectories(Directory workspaceDir) async {
    final envExamplesDir = Directory(p.join(workspaceDir.path, 'env_examples'));
    if (envExamplesDir.existsSync()) {
      await envExamplesDir.delete(recursive: true);
    }

    final hooksDir = Directory(p.join(workspaceDir.path, 'husky_hooks'));
    if (hooksDir.existsSync()) {
      await hooksDir.delete(recursive: true);
    }
  }
}

class BlocAppTemplate implements Template {
  BlocAppTemplate(this._packageRoot);

  final String _packageRoot;

  @override
  String get name => 'bloc_app';

  @override
  String get description =>
      'Single Flutter app with BLoC, clean architecture, and Drift.';

  @override
  TemplateKind get kind => TemplateKind.builtIn;

  @override
  Future<void> generate(TemplateContext context) async {
    await _ensureRequiredCommands();

    if (context.workspaceDir.existsSync()) {
      throw 'Target directory already exists: ${context.workspaceDir.path}';
    }

    final templateDir = Directory(p.join(_packageRoot, 'template', 'bloc_app'));
    if (!templateDir.existsSync()) {
      throw 'Template directory not found: ${templateDir.path}';
    }

    final appTemplateDir = Directory(p.join(templateDir.path, 'app_template'));
    if (!appTemplateDir.existsSync()) {
      throw 'Missing app_template in template.';
    }

    await _runFlutterCreate(
      appDir: context.workspaceDir,
      appName: context.appName,
      org: context.org,
      description: context.description,
    );

    await _copyDirectory(appTemplateDir, context.workspaceDir, overwrite: true);
    await _restoreHiddenTemplateEntries(context.workspaceDir);
    await _ensureGitignore(context.workspaceDir);
    await _replaceTokensInDirectory(
      context.workspaceDir,
      _buildTokenMap(context.variables),
    );
  }

  Future<void> _ensureRequiredCommands() async {
    if (!await _commandExists('flutter')) {
      throw 'Missing required command(s): flutter. '
          'Install it and ensure it is available on your PATH.';
    }
  }

  Future<void> _restoreHiddenTemplateEntries(Directory workspaceDir) async {
    // Pub packages omit hidden entries, so keep template dotfiles under
    // underscore-prefixed names and restore them after copying.
    const hiddenEntries = <String, String>{
      '_github': '.github',
      '_vscode': '.vscode',
      '_husky': '.husky',
      '_gitleaks.toml': '.gitleaks.toml',
    };

    for (final entry in hiddenEntries.entries) {
      final sourcePath = p.join(workspaceDir.path, entry.key);
      final targetPath = p.join(workspaceDir.path, entry.value);

      final sourceDir = Directory(sourcePath);
      if (sourceDir.existsSync()) {
        await _moveDirectory(sourceDir, Directory(targetPath));
        continue;
      }

      final sourceFile = File(sourcePath);
      if (sourceFile.existsSync()) {
        await _moveFile(sourceFile, File(targetPath));
      }
    }
  }

  Future<void> _moveDirectory(Directory source, Directory target) async {
    if (target.existsSync()) {
      await _copyDirectory(source, target, overwrite: false);
      await source.delete(recursive: true);
      return;
    }
    await source.rename(target.path);
  }

  Future<void> _moveFile(File source, File target) async {
    if (target.existsSync()) {
      await source.delete();
      return;
    }
    await target.parent.create(recursive: true);
    await source.rename(target.path);
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

    final process = await Process.start('flutter', args, runInShell: true);

    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw 'flutter create failed with exit code $exitCode';
    }
  }

  Future<void> _ensureGitignore(Directory workspaceDir) async {
    final source = File(p.join(workspaceDir.path, 'gitignore'));
    if (!source.existsSync()) {
      return;
    }

    final target = File(p.join(workspaceDir.path, '.gitignore'));
    if (!target.existsSync()) {
      await source.copy(target.path);
    }

    await source.delete();
  }
}

class ExternalTemplate implements Template {
  ExternalTemplate(this._source, {CliLogger? logger})
    : _logger = logger ?? CliLogger();

  final TemplateSource _source;
  final CliLogger _logger;

  @override
  String get name => _source.source;

  @override
  String get description => 'External template.';

  @override
  TemplateKind get kind => TemplateKind.external;

  @override
  Future<void> generate(TemplateContext context) async {
    if (context.workspaceDir.existsSync()) {
      throw 'Target directory already exists: ${context.workspaceDir.path}';
    }

    final materializer = TemplateMaterializer();
    final materialized = await materializer.materialize(_source);
    try {
      final templateRoot = _selectTemplateRoot(materialized.root, _source.path);
      final manifest = await TemplateManifest.load(templateRoot, _logger);
      final variables = _resolveTemplateVariables(context.variables, manifest);
      final tokens = _buildTokenMap(variables);

      await _copyDirectory(
        templateRoot,
        context.workspaceDir,
        shouldCopy: _shouldCopyTemplateEntry,
        pathTokens: tokens,
      );

      await _replaceTokensInDirectory(context.workspaceDir, tokens);

      await _runPostGenerate(context, manifest, templateRoot: templateRoot);
    } finally {
      if (materialized.shouldCleanup) {
        await materialized.root.delete(recursive: true);
      }
    }
  }

  bool _shouldCopyTemplateEntry(String relativePath) {
    final parts = p.split(relativePath);
    if (parts.contains('.git')) {
      return false;
    }
    final fileName = p.basename(relativePath).toLowerCase();
    if (fileName == 'template.yaml' ||
        fileName == 'template.yml' ||
        fileName == 'template.json') {
      return false;
    }
    return true;
  }

  Future<void> _runPostGenerate(
    TemplateContext context,
    TemplateManifest? manifest, {
    required Directory templateRoot,
  }) async {
    if (manifest == null || manifest.postGenerate.isEmpty) {
      return;
    }

    if (!context.allowScripts) {
      _logger.out(
        'Post-generate scripts are skipped. Re-run with --allow-scripts to enable.',
      );
      return;
    }

    if (context.skipSetup) {
      _logger.out('Post-generate scripts skipped (--skip-setup).');
      return;
    }

    final requiredCommands = manifest.requires;
    if (requiredCommands.isNotEmpty) {
      final missing = <String>[];
      for (final command in requiredCommands) {
        if (!await _commandExists(command)) {
          missing.add(command);
        }
      }
      if (missing.isNotEmpty) {
        throw 'Missing required command(s): ${missing.join(', ')}. '
            'Install them and ensure they are available on your PATH.';
      }
    }

    for (final command in manifest.postGenerate) {
      await _runShellCommand(command, context.workspaceDir);
    }
  }
}

class TemplateMaterializer {
  TemplateMaterializer();

  Future<MaterializedTemplate> materialize(TemplateSource source) async {
    switch (source.type) {
      case TemplateSourceType.directory:
        final dir = Directory(source.source);
        if (!dir.existsSync()) {
          throw 'Template path not found: ${dir.path}';
        }
        return MaterializedTemplate(dir, shouldCleanup: false);
      case TemplateSourceType.git:
        if (!await _commandExists('git')) {
          throw 'git is required to fetch template repositories.';
        }
        return _cloneGit(source);
      case TemplateSourceType.archive:
        return _extractArchive(source);
    }
  }

  Future<MaterializedTemplate> _cloneGit(TemplateSource source) async {
    final tempDir = await Directory.systemTemp.createTemp(
      'flutter_app_template_git_',
    );

    final cloneArgs = <String>['clone'];
    if (source.ref == null) {
      cloneArgs.addAll(['--depth', '1']);
    }
    cloneArgs.addAll([source.source, tempDir.path]);

    final cloneResult = await Process.run('git', cloneArgs, runInShell: true);

    if (cloneResult.exitCode != 0) {
      throw 'git clone failed: ${cloneResult.stderr}';
    }

    if (source.ref != null) {
      final checkoutResult = await Process.run(
        'git',
        ['checkout', source.ref!],
        workingDirectory: tempDir.path,
        runInShell: true,
      );
      if (checkoutResult.exitCode != 0) {
        throw 'git checkout failed: ${checkoutResult.stderr}';
      }
    }

    return MaterializedTemplate(tempDir, shouldCleanup: true);
  }

  Future<MaterializedTemplate> _extractArchive(TemplateSource source) async {
    final bytes = await _loadArchiveBytes(source.source);
    if (source.sha256 != null) {
      final digest = sha256.convert(bytes).toString();
      if (digest.toLowerCase() != source.sha256!.toLowerCase()) {
        throw 'SHA-256 mismatch for ${source.source}.';
      }
    }

    final archive = _decodeArchive(bytes, source.source);
    final tempDir = await Directory.systemTemp.createTemp(
      'flutter_app_template_archive_',
    );
    _extractArchiveToDirectory(archive, tempDir);
    return MaterializedTemplate(tempDir, shouldCleanup: true);
  }

  Future<Uint8List> _loadArchiveBytes(String source) async {
    if (_looksLikeArchive(source)) {
      final file = File(source);
      if (file.existsSync()) {
        return Uint8List.fromList(await file.readAsBytes());
      }
    }

    final uri = Uri.tryParse(source);
    if (uri == null || (!uri.hasScheme)) {
      throw 'Template archive not found: $source';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw 'Template archive must be a file path or http(s) URL.';
    }

    final client = HttpClient();
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw 'Failed to download template archive: HTTP ${response.statusCode}';
    }

    final builder = BytesBuilder();
    await for (final chunk in response) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  Archive _decodeArchive(Uint8List bytes, String source) {
    final lower = source.toLowerCase();
    if (lower.endsWith('.zip')) {
      return ZipDecoder().decodeBytes(bytes);
    }
    if (lower.endsWith('.tar.gz') || lower.endsWith('.tgz')) {
      final tarData = GZipDecoder().decodeBytes(bytes);
      return TarDecoder().decodeBytes(tarData);
    }
    if (lower.endsWith('.tar')) {
      return TarDecoder().decodeBytes(bytes);
    }
    throw 'Unsupported archive format: $source';
  }

  void _extractArchiveToDirectory(Archive archive, Directory target) {
    for (final file in archive) {
      final normalized = p.normalize(p.join(target.path, file.name));
      if (!p.isWithin(target.path, normalized)) {
        throw 'Archive entry is outside target directory: ${file.name}';
      }
      if (file.isFile) {
        final output = File(normalized);
        output.parent.createSync(recursive: true);
        final content = file.content as List<int>;
        output.writeAsBytesSync(content);
      } else {
        Directory(normalized).createSync(recursive: true);
      }
    }
  }
}

class MaterializedTemplate {
  MaterializedTemplate(this.root, {required this.shouldCleanup});

  final Directory root;
  final bool shouldCleanup;
}

Directory _selectTemplateRoot(Directory root, String? subdir) {
  if (subdir != null && subdir.trim().isNotEmpty) {
    final selected = Directory(p.join(root.path, subdir));
    if (!selected.existsSync()) {
      throw 'Template path not found: ${selected.path}';
    }
    return selected;
  }

  final entities = root.listSync(followLinks: false);
  final directories = <Directory>[];
  var hasFile = false;
  for (final entity in entities) {
    if (entity is Directory) {
      directories.add(entity);
    } else if (entity is File) {
      hasFile = true;
    }
  }
  if (!hasFile && directories.length == 1) {
    return directories.first;
  }
  return root;
}

class TemplateManifest {
  TemplateManifest({
    required this.name,
    required this.description,
    required this.variables,
    required this.postGenerate,
    required this.requires,
  });

  final String? name;
  final String? description;
  final Map<String, TemplateVariable> variables;
  final List<String> postGenerate;
  final List<String> requires;

  static Future<TemplateManifest?> load(
    Directory templateRoot,
    CliLogger logger,
  ) async {
    final yamlFile = File(p.join(templateRoot.path, 'template.yaml'));
    final ymlFile = File(p.join(templateRoot.path, 'template.yml'));
    final jsonFile = File(p.join(templateRoot.path, 'template.json'));

    if (await yamlFile.exists()) {
      return _parseYaml(await yamlFile.readAsString(), logger);
    }
    if (await ymlFile.exists()) {
      return _parseYaml(await ymlFile.readAsString(), logger);
    }
    if (await jsonFile.exists()) {
      return _parseJson(await jsonFile.readAsString(), logger);
    }
    return null;
  }

  static TemplateManifest _parseYaml(String content, CliLogger logger) {
    try {
      final data = loadYaml(content);
      return _parseManifest(data);
    } catch (error) {
      logger.err('Failed to parse template.yaml: $error');
      rethrow;
    }
  }

  static TemplateManifest _parseJson(String content, CliLogger logger) {
    try {
      final data = jsonDecode(content);
      return _parseManifest(data);
    } catch (error) {
      logger.err('Failed to parse template.json: $error');
      rethrow;
    }
  }

  static TemplateManifest _parseManifest(dynamic data) {
    if (data is! Map) {
      throw 'Template manifest must be a map.';
    }

    final name = data['name']?.toString();
    final description = data['description']?.toString();
    final variables = <String, TemplateVariable>{};
    final rawVariables = data['variables'];
    if (rawVariables is Map) {
      for (final entry in rawVariables.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is Map) {
          variables[key] = TemplateVariable(
            description: value['description']?.toString(),
            defaultValue: value['default']?.toString(),
            required: value['required'] == true,
          );
        } else if (value is String) {
          variables[key] = TemplateVariable(
            description: null,
            defaultValue: value,
            required: false,
          );
        }
      }
    }

    final postGenerate = <String>[];
    final rawPost = data['post_generate'];
    if (rawPost is List) {
      for (final entry in rawPost) {
        if (entry is String) {
          postGenerate.add(entry);
        } else if (entry is Map && entry['command'] != null) {
          postGenerate.add(entry['command'].toString());
        }
      }
    }

    final requires = <String>[];
    final rawRequires = data['requires'];
    if (rawRequires is List) {
      for (final entry in rawRequires) {
        requires.add(entry.toString());
      }
    }

    return TemplateManifest(
      name: name,
      description: description,
      variables: variables,
      postGenerate: postGenerate,
      requires: requires,
    );
  }
}

class TemplateVariable {
  TemplateVariable({
    required this.description,
    required this.defaultValue,
    required this.required,
  });

  final String? description;
  final String? defaultValue;
  final bool required;
}

Map<String, String> _resolveTemplateVariables(
  Map<String, String> baseVariables,
  TemplateManifest? manifest,
) {
  final resolved = Map<String, String>.from(baseVariables);
  if (manifest == null) {
    return _addDerivedVariables(resolved);
  }

  for (final entry in manifest.variables.entries) {
    if (resolved.containsKey(entry.key) &&
        resolved[entry.key]!.trim().isNotEmpty) {
      continue;
    }
    final defaultValue = entry.value.defaultValue;
    if (defaultValue != null) {
      resolved[entry.key] = _renderString(defaultValue, resolved);
    }
  }

  final missing = <String>[];
  for (final entry in manifest.variables.entries) {
    if (entry.value.required &&
        (!resolved.containsKey(entry.key) ||
            resolved[entry.key]!.trim().isEmpty)) {
      missing.add(entry.key);
    }
  }

  if (missing.isNotEmpty) {
    throw 'Missing required template variables: ${missing.join(', ')}.';
  }

  for (final entry in resolved.entries.toList()) {
    resolved[entry.key] = _renderString(entry.value, resolved);
  }

  return _addDerivedVariables(resolved);
}

Map<String, String> _addDerivedVariables(Map<String, String> variables) {
  final resolved = Map<String, String>.from(variables);
  if (!resolved.containsKey('app_id')) {
    final org = resolved['org'];
    final appName = resolved['app_name'];
    if (org != null &&
        org.isNotEmpty &&
        appName != null &&
        appName.isNotEmpty) {
      resolved['app_id'] = '$org.$appName';
    }
  }

  final org = resolved['org'];
  if (org != null && org.isNotEmpty) {
    resolved['org_path'] = org.replaceAll('.', '/');
  }

  final appId = resolved['app_id'];
  if (appId != null && appId.isNotEmpty) {
    resolved['app_id_path'] = appId.replaceAll('.', '/');
  }

  return resolved;
}

String _renderString(String value, Map<String, String> variables) {
  var output = value;
  for (final entry in variables.entries) {
    output = output.replaceAll('{{${entry.key}}}', entry.value);
    output = output.replaceAll('{{${entry.key.toUpperCase()}}}', entry.value);
    output = output.replaceAll('__${entry.key.toUpperCase()}__', entry.value);
  }
  return output;
}

Map<String, String> _buildTokenMap(Map<String, String> variables) {
  final tokens = <String, String>{};
  for (final entry in variables.entries) {
    tokens['__${entry.key.toUpperCase()}__'] = entry.value;
    tokens['{{${entry.key}}}'] = entry.value;
    tokens['{{${entry.key.toUpperCase()}}}'] = entry.value;
  }
  return tokens;
}

Future<void> _copyDirectory(
  Directory source,
  Directory destination, {
  bool overwrite = true,
  bool Function(String relativePath)? shouldCopy,
  Map<String, String>? pathTokens,
  String? rootPath,
}) async {
  rootPath ??= source.path;
  await destination.create(recursive: true);

  await for (final entity in source.list(followLinks: false)) {
    final relative = p.relative(entity.path, from: rootPath);
    final mappedRelative = pathTokens == null
        ? relative
        : _applyTokens(relative, pathTokens);
    final mappedPath = p.normalize(p.join(destination.path, mappedRelative));
    if (!p.isWithin(destination.path, mappedPath) &&
        mappedPath != destination.path) {
      throw 'Refusing to write outside destination: $mappedRelative';
    }
    if (shouldCopy != null && !shouldCopy(relative)) {
      continue;
    }
    if (entity is File) {
      final target = File(mappedPath);
      if (target.existsSync() && !overwrite) {
        continue;
      }
      await target.parent.create(recursive: true);
      await entity.copy(mappedPath);
    } else if (entity is Directory) {
      await Directory(mappedPath).create(recursive: true);
      await _copyDirectory(
        Directory(entity.path),
        destination,
        overwrite: overwrite,
        shouldCopy: shouldCopy,
        pathTokens: pathTokens,
        rootPath: rootPath,
      );
    }
  }
}

String _applyTokens(String value, Map<String, String> tokens) {
  var output = value;
  for (final entry in tokens.entries) {
    output = output.replaceAll(entry.key, entry.value);
  }
  return output;
}

Future<void> _replaceTokensInDirectory(
  Directory root,
  Map<String, String> tokens,
) async {
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) {
      continue;
    }

    if (!_isTextFile(entity.path)) {
      continue;
    }

    final content = await entity.readAsString();
    var updated = content;
    for (final entry in tokens.entries) {
      updated = updated.replaceAll(entry.key, entry.value);
    }

    if (updated != content) {
      await entity.writeAsString(updated);
    }
  }
}

bool _isTextFile(String path) {
  final extension = p.extension(path).toLowerCase();
  const textExtensions = {
    '.dart',
    '.yaml',
    '.yml',
    '.md',
    '.txt',
    '.json',
    '.xml',
    '.gradle',
    '.kts',
    '.toml',
    '.properties',
    '.xcconfig',
    '.sh',
    '.kt',
    '.java',
    '.swift',
    '.m',
    '.mm',
    '.c',
    '.cc',
    '.cpp',
    '.h',
    '.hpp',
    '.rc',
    '.plist',
    '.pbxproj',
    '.xcscheme',
    '.xcworkspacedata',
    '.storyboard',
    '.entitlements',
    '.html',
    '.htm',
    '.css',
    '.js',
  };
  if (textExtensions.contains(extension)) {
    return true;
  }

  final fileName = p.basename(path).toLowerCase();
  const textFileNames = {
    'makefile',
    'dockerfile',
    '.gitignore',
    'license',
    'readme',
    'changelog',
  };
  if (textFileNames.contains(fileName)) {
    return true;
  }
  if (fileName.startsWith('.env')) {
    return true;
  }
  return false;
}

Future<bool> _commandExists(String command) async {
  final result = await Process.run(
    Platform.isWindows ? 'where' : 'command',
    Platform.isWindows ? [command] : ['-v', command],
    runInShell: true,
  );

  return result.exitCode == 0;
}

Future<void> _runShellCommand(
  String command,
  Directory workingDirectory,
) async {
  final shell = Platform.isWindows ? 'cmd' : 'bash';
  final args = Platform.isWindows ? ['/c', command] : ['-lc', command];
  final process = await Process.start(
    shell,
    args,
    workingDirectory: workingDirectory.path,
    runInShell: true,
  );

  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw 'Command failed ($exitCode): $command';
  }
}
