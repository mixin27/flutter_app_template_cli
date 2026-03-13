# Flutter Template Checklist

Use this checklist to convert a Flutter app into a reusable template.

## 1. Clean up generated output

Remove files that should not be committed in a template:
1. `.dart_tool/`
2. `build/`
3. `ios/Pods/`
4. `android/.gradle/`
5. IDE folders (`.idea/`, `.vscode/`) as needed

## 2. Add a template manifest

Create `template.yaml` at the template root with variables and optional scripts.

Example:

```yaml
name: my-template
description: Example Flutter template
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

## 3. Replace hardcoded values with tokens

Recommended tokens:
1. `__APP_NAME__`
2. `__WORKSPACE_NAME__`
3. `__ORG__`
4. `__DESCRIPTION__`
5. `{{variable_name}}` for custom variables

Common files to replace:
1. `pubspec.yaml` (`name`, `description`)
2. `android/app/build.gradle` (`applicationId`)
3. `android/app/src/main/AndroidManifest.xml` (`package`)
4. `android/app/src/debug/AndroidManifest.xml` (`package`)
5. `android/app/src/profile/AndroidManifest.xml` (`package`)
6. `android/app/src/main/kotlin/.../MainActivity.kt` (`package`)
7. `android/app/src/main/java/.../MainActivity.java` (`package`)
8. `ios/Runner/Info.plist` (bundle identifiers)
9. `ios/Runner.xcodeproj/project.pbxproj` (bundle identifiers)
10. `macos/Runner.xcodeproj/project.pbxproj` (bundle identifiers)
11. `linux/` and `windows/` project files if enabled

## 4. Use tokenized paths for package folders

If your template includes Android Kotlin/Java paths like:

```
android/app/src/main/kotlin/com/example/my_app/MainActivity.kt
```

Rename them to:

```
android/app/src/main/kotlin/__ORG_PATH__/__APP_NAME__/MainActivity.kt
```

The CLI will replace `__ORG_PATH__` with `com/example` and `__APP_NAME__` with
the chosen app name.

## 5. Validate with a local run

```bash
flutter_app_template_cli create demo_workspace \
  --template /path/to/template \
  --var app_name=demo_app \
  --var org=com.example
```

## 6. Publish the template

```bash
git init
git add .
git commit -m "Initial template"
git push -u origin main
```
