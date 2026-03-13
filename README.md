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

Skip the automatic setup (useful if you want to run it later):

```bash
flutter_app_template_cli create my_workspace --skip-setup
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

By default, the CLI runs `make env-init` and `make setup-dev` for you. If you
used `--skip-setup`, run the setup manually:

```bash
cd my_workspace
./scripts/setup_dev.sh
```

Or:

```bash
make setup-dev
```
