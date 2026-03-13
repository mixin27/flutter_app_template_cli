# Template Creator Guide

This guide explains how to build a reusable Flutter template that works with
`flutter_app_template_cli`.

It covers:
1. Creating a template from `flutter create`.
2. Converting the project into a reusable template.
3. Publishing it to Git.
4. Using it with the CLI.

## 1. Create a base app

```bash
flutter create --org com.example my_app
cd my_app
```

You now have a clean Flutter app scaffold to customize.

## 2. Customize the project structure

Decide what you want every generated project to include:
1. Folder structure (features, core, data, etc).
2. Dependencies and tooling (lint, CI, scripts).
3. Example code and documentation.

Remove anything that should not ship inside a template:
1. `.dart_tool/`
2. `build/`
3. `ios/Pods/`
4. `android/.gradle/`
5. IDE config folders if desired (`.idea/`, `.vscode/`)

## 3. Add a template manifest

Create `template.yaml` in the project root.

Example:

```yaml
name: flutter-app-template
description: Starter Flutter app template
variables:
  app_name:
    description: Dart package name (snake_case).
    default: my_app
    required: true
  org:
    description: Organization identifier (reverse DNS).
    default: com.example
    required: true
  description:
    description: App description shown in pubspec.yaml.
    default: A Flutter app.
post_generate:
  - command: flutter pub get
requires:
  - flutter
```

Notes:
1. `variables` can define defaults and required fields.
2. `post_generate` runs only when users pass `--allow-scripts`.
3. `requires` lists the commands needed for `post_generate`.

## 4. Replace hardcoded values with tokens

Replace project-specific values with tokens so the CLI can substitute values.

### Common tokens

1. `__APP_NAME__`
2. `__WORKSPACE_NAME__`
3. `__ORG__`
4. `__DESCRIPTION__`
5. `{{variable_name}}` (from `template.yaml` or `--var`)

### Required replacements (typical Flutter project)

1. `pubspec.yaml`
   - `name: __APP_NAME__`
   - `description: __DESCRIPTION__`
2. Android:
   - `android/app/build.gradle` or `android/app/build.gradle.kts`
     - `applicationId = "__ORG__.__APP_NAME__"`
     - `namespace = "__ORG__.__APP_NAME__"`
   - `android/app/src/main/AndroidManifest.xml`
     - `package="__ORG__.__APP_NAME__"`
   - `android/app/src/debug/AndroidManifest.xml`
   - `android/app/src/profile/AndroidManifest.xml`
   - `android/app/src/main/kotlin/.../MainActivity.kt`
   - `android/app/src/main/java/.../MainActivity.java`
3. iOS:
   - `ios/Runner/Info.plist`
   - `ios/Runner.xcodeproj/project.pbxproj`
   - `ios/Runner/Runner.entitlements`
4. macOS:
   - `macos/Runner.xcodeproj/project.pbxproj`
5. Web:
   - `web/index.html` (app title)
6. Windows and Linux:
   - `windows/runner/*.rc`
   - `linux/runner/*.cc`

## 5. Tokenize package folder paths

Android Kotlin/Java folders include the org package path. Example:

```
android/app/src/main/kotlin/com/example/my_app/MainActivity.kt
```

Rename this to:

```
android/app/src/main/kotlin/__ORG_PATH__/__APP_NAME__/MainActivity.kt
```

The CLI replaces:
1. `__ORG_PATH__` with `com/example`
2. `__APP_NAME__` with the chosen app name

## 6. Validate locally

Test with a local template directory:

```bash
flutter_app_template_cli create demo_workspace \
  --template /path/to/template \
  --var app_name=demo_app \
  --var org=com.example \
  --var description="Demo app"
```

Inspect the generated folder to verify:
1. No leftover tokens.
2. Package name and bundle IDs replaced correctly.
3. Folder paths are correct (`android/.../__ORG_PATH__/__APP_NAME__/`).

## 7. Publish to Git

```bash
git init
git add .
git commit -m "Initial Flutter template"
git push -u origin main
```

## 8. Use the Git template with the CLI

```bash
flutter_app_template_cli create my_workspace \
  --template https://github.com/your-org/flutter-template \
  --template-ref main \
  --var app_name=my_app \
  --var org=com.example \
  --var description="My Flutter app"
```

If your template is in a subfolder:

```bash
flutter_app_template_cli create my_workspace \
  --template https://github.com/your-org/flutter-template \
  --template-ref main \
  --template-path templates/flutter_app \
  --var app_name=my_app
```

## 9. Add scripts safely

If you need post-generate scripts:
1. Add them to `template.yaml` under `post_generate`.
2. List dependencies under `requires`.
3. Users must pass `--allow-scripts` to run them.

## 10. Troubleshooting

### Tokens not replaced
1. Ensure you used supported tokens (`__APP_NAME__`, `__ORG__`, `{{var}}`).
2. Ensure the file is a text file. The CLI replaces tokens in common Flutter
   file types (`.dart`, `.yaml`, `.kt`, `.plist`, `.pbxproj`, `.html`, etc).
3. Run `rg "{{|__APP_NAME__|__ORG__" <generated_dir>` to find leftovers.

### Wrong Android package folders
Make sure you renamed the Kotlin/Java directory path to:

```
android/app/src/main/kotlin/__ORG_PATH__/__APP_NAME__/
```

### Post-generate scripts not running
They only run when `--allow-scripts` is provided, and they are skipped when
`--skip-setup` is set.
