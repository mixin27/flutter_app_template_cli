# flutter_app_template_cli

Generate a Flutter monorepo workspace with `apps/` and `packages/`, plus a ready-to-run app template.

## Install

```bash
dart pub global activate flutter_app_template_cli
```

## Usage

```bash
flutter_app_template_cli create my_workspace \
  --app-name my_app \
  --org com.example \
  --description "My Flutter app"
```

## What it creates

```
my_workspace/
  apps/
    my_app/
  packages/
  docs/
  scripts/
  Makefile
  pubspec.yaml
```

## After creation

```bash
cd my_workspace
./scripts/setup_dev.sh
```

Or:

```bash
make setup-dev
```
