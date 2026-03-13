# flutter_app_template_cli

Generate Flutter workspaces from built-in or third-party templates.

This CLI supports:
1. Built-in templates (current monorepo and future ones).
2. Local template directories.
3. Git repositories (HTTPS or SSH).
4. Template archives (`.zip`, `.tar`, `.tar.gz`, `.tgz`) with optional checksums.

## Install

```bash
dart pub global activate flutter_app_template_cli
```

## Quick start (built-in monorepo)

```bash
flutter_app_template_cli create my_workspace \
  --app-name my_app \
  --org com.example \
  --description "My Flutter app"
```

If you omit `--app-name` for the monorepo template, the CLI will default to
`<workspace>_app` to avoid pub workspace name collisions.

By default, the CLI runs `make env-init` and `make setup-dev`. Skip that if
you want to run it later:

```bash
flutter_app_template_cli create my_workspace --skip-setup
```

## Use cases

### 1. Use a built-in template explicitly

```bash
flutter_app_template_cli create my_workspace --template monorepo
```

### 2. Use a local template directory

```bash
flutter_app_template_cli create my_workspace \
  --template /path/to/template \
  --var api_base_url=https://api.example.com
```

### 3. Use a Git template (HTTPS or SSH)

```bash
flutter_app_template_cli create my_workspace \
  --template https://github.com/org/repo \
  --template-ref v1.2.0
```

```bash
flutter_app_template_cli create my_workspace \
  --template git@github.com:org/repo.git \
  --template-ref main
```

### 4. Use a template archive (with optional checksum)

```bash
flutter_app_template_cli create my_workspace \
  --template https://example.com/templates/monorepo.tgz \
  --template-sha256 <sha256>
```

```bash
flutter_app_template_cli create my_workspace \
  --template /path/to/template.zip
```

### 5. Use a subdirectory inside a template source

```bash
flutter_app_template_cli create my_workspace \
  --template https://github.com/org/repo \
  --template-ref v1.2.0 \
  --template-path templates/flutter_monorepo
```

### 6. Register a template for reuse

```bash
flutter_app_template_cli template add my_template \
  https://github.com/org/repo \
  --ref v1.2.0 \
  --path templates/monorepo
```

```bash
flutter_app_template_cli create my_workspace --template my_template
```

### 7. List and remove registered templates

```bash
flutter_app_template_cli template list
flutter_app_template_cli template remove my_template
```

### 8. Pass custom variables into templates

```bash
flutter_app_template_cli create my_workspace \
  --template /path/to/template \
  --var api_base_url=https://api.example.com \
  --var feature_flag=true
```

### 9. Allow post-generate scripts

External templates can define `post_generate` commands. These are disabled by
default. Enable them explicitly:

```bash
flutter_app_template_cli create my_workspace \
  --template /path/to/template \
  --allow-scripts
```

`--skip-setup` also skips post-generate scripts.

## Template manifest

Third-party templates can include `template.yaml` (or `template.json`) to define
variables and optional post-generate commands.

Example `template.yaml`:

```yaml
name: my-template
description: Example template
variables:
  api_base_url:
    description: Base URL for API calls
    default: https://api.example.com
    required: true
  feature_flag:
    default: false
post_generate:
  - command: make setup-dev
requires:
  - make
  - dart
```

`requires` is checked before running scripts, and scripts run only when
`--allow-scripts` is provided.

## Token replacement

Templates can use tokens that are replaced during generation. The CLI replaces:

1. `__WORKSPACE_NAME__` from the workspace name.
2. `__APP_NAME__` from the app name.
3. `__ORG__` and `__DESCRIPTION__` from CLI flags.
4. `{{variable_name}}` from `--var` or `template.yaml` defaults.

Example:

```
__WORKSPACE_NAME__
{{api_base_url}}
```

## Notes

1. Built-in templates may require `flutter`, `git`, and `make` to be installed.
2. External templates do not assume Flutter tooling, but their scripts might.

## Starter template demo

You can find a ready-to-push starter template at [demo_flutter_template](https://github.com/mixin27/demo_flutter_template)

You can clone and push that template to its own Git repo and use it directly with:

```bash
flutter_app_template_cli create my_workspace \
  --template https://github.com/your-org/flutter_app_template \
  --template-ref main
```

For a full conversion checklist, see `documentation/template_checklist.md`.
For a full walkthrough, see `documentation/template_creator_guide.md`.
