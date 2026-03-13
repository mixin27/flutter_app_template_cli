# Native Flavors (Optional)

This template already supports environment switching via Dart entrypoints and
`--dart-define` values (see `lib/main_development.dart`, `lib/main_staging.dart`,
`lib/main_production.dart`). Native platform flavors are optional and only needed
if you want separate bundle IDs, app display names, icons, or per-flavor native
configuration.

Quick scaffold command (Android + iOS schemes/xcconfig):

```bash
./scripts/enable_native_flavors.sh
```

Or via Makefile:

```bash
make enable-native-flavors
```

To limit to a platform or overwrite existing files:

```bash
./scripts/enable_native_flavors.sh --platform android
./scripts/enable_native_flavors.sh --platform ios --force
```

## When to enable native flavors

Enable native flavors if you need:

- different bundle IDs (e.g. `.dev`, `.staging`)
- different app names or icons per environment
- per-flavor Firebase files wired at build time

If you only need different API endpoints or feature flags, the Dart entrypoints
+ `--dart-define` are enough.

## Android (productFlavors)

Edit `apps/<app>/android/app/build.gradle.kts` (Kotlin DSL) and add:

```kotlin
android {
    flavorDimensions += "environment"

    productFlavors {
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "__APP_NAME__ Dev")
        }

        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "__APP_NAME__ Staging")
        }

        create("production") {
            dimension = "environment"
            resValue("string", "app_name", "__APP_NAME__")
        }
    }
}
```

If your project uses `build.gradle` (Groovy), translate the snippet to Groovy.

Run with:

```bash
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor production -t lib/main_production.dart
```

## iOS (schemes + xcconfig)

For iOS, create build configurations + schemes for each flavor:

1. Duplicate `Debug.xcconfig`, `Release.xcconfig`, and `Profile.xcconfig` into
   `Debug-development.xcconfig`, `Release-development.xcconfig`, etc.
2. In Xcode, add build configurations:
   - `Debug-development`, `Debug-staging`, `Debug-production`
   - `Release-development`, `Release-staging`, `Release-production`
   - `Profile-development`, `Profile-staging`, `Profile-production`
3. Create schemes that point at the matching configuration.
4. Update `Runner` app display name or bundle ID per configuration as needed.

Then run:

```bash
flutter run --flavor development -t lib/main_development.dart
```

## VS Code launch configs

A workspace `launch.json` is provided with both standard Dart entrypoint runs
and an optional native-flavor configuration. See `.vscode/launch.json`.

## CI note

The release workflow is flavor-aware. If you keep native flavors disabled,
update the workflow to remove `--flavor` or add a toggle before running it.
