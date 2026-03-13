# Firebase and Signing Setup

This project supports flavor-specific Firebase config and CI-ready signing for Android and iOS.

## Flavor files (local, git-ignored)

Android:

- `apps/<app>/android/firebase/development/google-services.json`
- `apps/<app>/android/firebase/staging/google-services.json`
- `apps/<app>/android/firebase/production/google-services.json`

iOS:

- `apps/<app>/ios/firebase/development/GoogleService-Info.plist`
- `apps/<app>/ios/firebase/staging/GoogleService-Info.plist`
- `apps/<app>/ios/firebase/production/GoogleService-Info.plist`

These files are ignored by git.

## Local preparation command

```bash
make prepare-firebase FLAVOR=development
```

Equivalent:

```bash
./scripts/prepare_firebase.sh --flavor development
```

What it does:

- copies Android JSON to `apps/<app>/android/app/src/<flavor>/google-services.json`
- validates iOS plist presence (Xcode copies from `apps/<app>/ios/firebase/<flavor>/...` automatically)

## Android signing (local)

1. Copy template:

```bash
cp apps/<app>/android/key.properties.example apps/<app>/android/key.properties
```

2. Place keystore at `apps/<app>/android/app/upload-keystore.jks` (or update `storeFile` in `apps/<app>/android/key.properties`).

Release build uses `apps/<app>/android/key.properties` when available, otherwise falls back to debug signing.

## CI release workflow

Use `.github/workflows/release_build.yml` via `workflow_dispatch`.

Inputs:

- `flavor`: `development|staging|production`
- `platform`: `android|ios|both`
- `sign_ios`: `true|false`
- `ios_export_method`: `app-store|ad-hoc|enterprise|development` (used when `sign_ios=true`)

Outputs:

- Android: `.aab`
- iOS (signed): `.ipa`
- iOS (unsigned): `Runner.app`

## Required GitHub secrets

Android Firebase (optional, per flavor):

- `ANDROID_FIREBASE_DEVELOPMENT_JSON_B64`
- `ANDROID_FIREBASE_STAGING_JSON_B64`
- `ANDROID_FIREBASE_PRODUCTION_JSON_B64`

iOS Firebase (optional, per flavor):

- `IOS_FIREBASE_DEVELOPMENT_PLIST_B64`
- `IOS_FIREBASE_STAGING_PLIST_B64`
- `IOS_FIREBASE_PRODUCTION_PLIST_B64`

Android signing (required for Android release build):

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

iOS signing (required when `sign_ios=true`):

- `IOS_P12_BASE64`
- `IOS_P12_PASSWORD`
- `IOS_PROVISIONING_PROFILE_BASE64`
- `IOS_KEYCHAIN_PASSWORD` (optional, workflow can generate one)

## Notes

- Android Firebase Gradle plugin is opt-in via `ENABLE_FIREBASE_ANDROID=true`.
- In CI, workflow auto-enables it only when a flavor JSON is present.
- iOS uses a custom build phase: `[__APP_NAME__] Copy Firebase plist`.
