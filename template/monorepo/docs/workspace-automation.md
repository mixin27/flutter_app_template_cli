# Workspace Automation Scripts

This project uses Dart pub workspace and multiple local packages. These scripts standardize common operations across root + workspace members.

## Script location

- `scripts/`

## Available scripts

- `./scripts/workspace_list.sh`
  - print workspace members from root `pubspec.yaml`
- `./scripts/workspace_exec.sh [--with-root] -- <command> [args...]`
  - run any command across workspace members
- `./scripts/pub_get_all.sh`
  - run dependency resolution for root and every workspace package
- `./scripts/analyze_all.sh [--skip-root] [--skip-packages]`
  - run static analysis across app and packages
- `./scripts/test_all.sh [--skip-root] [--skip-packages]`
  - run tests across app and packages
- `./scripts/format_all.sh [--changed] [--check]`
  - format all Dart files, or only changed files
- `./scripts/codegen_all.sh [--no-delete-conflicting-outputs]`
  - run build_runner where configured
- `./scripts/clean_all.sh`
  - clean root and package build artifacts
- `./scripts/check_all.sh`
  - run pub-get, analyze, and test in one command
- `./scripts/setup_dev.sh [--with-ios-pods]`
  - one-time local setup: dependencies + git hooks + optional `.env` init + codegen (+ optional iOS pods)
- `./scripts/env_init.sh [--environment development|staging|production] [--force]`
  - create local `.env` from environment template
- `./scripts/secret_scan.sh [--staged]`
  - scan for leaked secrets using `gitleaks` (local binary or docker fallback)
- `./scripts/deps_outdated.sh [--skip-root] [--skip-packages] [--transitive] [--show-all] [--prereleases] [--no-dev]`
  - check outdated dependencies across root + workspace packages
- `./scripts/deps_upgrade.sh [--major] [--dry-run] [--tighten] [--skip-root] [--skip-packages]`
  - upgrade dependencies across root + workspace packages
- `./scripts/create_package.sh --name <package_name> [--kind dart|flutter]`
  - generate a new workspace package under `packages/` and update root workspace members
- `./scripts/create_feature.sh --name <feature_name> [--entity <PascalCase>] [--print-di-snippet] [--print-router-snippet] [--no-tests]`
  - scaffold a Clean Architecture feature with data/domain/presentation + `ResultBloc` pattern
  - includes feature DI module scaffold (`di/<feature>_module.dart`)
  - generates baseline tests for repository/usecase/bloc by default
- `./scripts/prepare_firebase.sh --flavor <development|staging|production> [--platform all|android|ios] [--required]`
  - prepare flavor Firebase config for native builds
- `./scripts/ci/install_firebase_from_secrets.sh <development|staging|production> [all|android|ios]`
  - CI helper to install flavor Firebase files from base64 secrets
- `./scripts/ci/setup_android_signing.sh [--required]`
  - CI helper to create `apps/<app>/android/key.properties` + keystore from secrets
- `./scripts/ci/setup_ios_signing.sh [--required]`
  - CI helper to import iOS cert/profile into keychain for signed IPA

## Makefile shortcuts

Equivalent `make` targets are available:

```bash
make pub-get
make analyze
make test
make check
make format
make format-check
make format-changed
make codegen
make clean
make workspace-list
make install-hooks
make env-init
make setup-dev
make secret-scan
make deps-outdated
make deps-upgrade
make deps-upgrade-major
make prepare-firebase FLAVOR=development
```

## Typical team workflows

### Before opening a PR

```bash
make secret-scan
make format-changed
make check
```

### After pulling latest changes

```bash
make pub-get
make analyze
```

### Dependency maintenance (workspace)

Routine audit + safe upgrade:

```bash
make deps-outdated
make deps-upgrade
make check
```

Major version upgrade pass:

```bash
make deps-upgrade-major DRY_RUN=1
make deps-upgrade-major
make codegen
make check
```

### After schema/model changes requiring generated files

```bash
make codegen
make analyze
make test
```

### One-time local Git hook setup

```bash
make install-hooks
```

This runs `dart run husky install`, sets `core.hooksPath=.husky`, and enables:

- `.husky/pre-push`
  - runs staged secret scan when local `gitleaks` is installed (`./scripts/secret_scan.sh --staged`)
  - runs `./scripts/format_all.sh --check`
  - runs `./scripts/check_all.sh`
  - blocks push if protected files are tracked:
    - `.env`, `.env.*` (except approved `*.example` templates)
    - `lib/app/config/app_envied.g.dart`
    - Firebase config files (`google-services.json`, `GoogleService-Info.plist`)
    - Android signing files (`apps/<app>/android/key.properties`, keystore files)

Commit message validation:

- `.husky/commit-msg` runs `commitlint_cli` with `commitlint.yaml`.

To bypass commit-msg once:

```bash
git commit --no-verify
```

If you need to bypass once:

```bash
SKIP_PRE_PUSH=1 git push
```

If you only need to skip the optional staged secret scan:

```bash
SKIP_SECRET_SCAN=1 git push
```

### First-time contributor setup

```bash
make setup-dev
```

With options:

```bash
make setup-dev ENV=staging
make setup-dev ENV=production FORCE_ENV=1 IOS_PODS=1
```

### Create a new shared package

```bash
make create-package NAME=app_analytics
make create-package NAME=app_ui_foundation KIND=flutter
```

### Create a new feature scaffold

```bash
make create-feature NAME=campaigns ENTITY=Campaign
make create-feature NAME=menu_items ENTITY=MenuItem
make create-feature NAME=campaigns ENTITY=Campaign PRINT_DI=1
make create-feature NAME=campaigns ENTITY=Campaign PRINT_ROUTER=1
make create-feature-api NAME=campaigns ENTITY=Campaign
make create-feature-api NAME=menu_items ENTITY=MenuItem
```

## CI suggestion

Minimum CI pipeline:

1. `./scripts/pub_get_all.sh`
2. `./scripts/secret_scan.sh`
3. `./scripts/codegen_all.sh`
4. `./scripts/format_all.sh --check`
5. `./scripts/analyze_all.sh`
6. `./scripts/test_all.sh`

Sample GitHub Actions workflow is available at:

- `.github/workflows/ci.yml`
  - runs on `pull_request` and `workflow_dispatch`
  - runs secret scan (`gitleaks`) and quality checks in separate jobs
  - skips docs-only changes (`docs/**`, `**/*.md`)
- `.github/workflows/release_build.yml`
  - manual `workflow_dispatch` release build (Android/iOS)
  - supports flavor input + optional signed iOS IPA path
  - uploads build artifacts for each selected platform

## Notes

- Scripts read workspace members from root `pubspec.yaml` automatically.
- `test_all.sh` skips package-level tests when no `_test.dart` file exists.
- `format_all.sh --changed` includes both modified and untracked Dart files.
- `create_feature.sh` and `create_feature_api_service.sh` print manual wiring steps for DI and router after generation.
- use `--print-di-snippet` to print copy-paste module import + module list entry for DI.
- use `--print-router-snippet` to print copy-paste route path + router branch snippets.
- if you update `.env` values (Envied), rerun `make codegen`.
- staged-only secret scan shortcut: `make secret-scan STAGED=1`.
- `STAGED=1` requires local `gitleaks` CLI; full-repo scan can use Docker fallback.
