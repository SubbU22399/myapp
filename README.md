# Cosmo Quest Build Instructions

This document provides instructions for creating production and pre-production builds for the Cosmo Quest application.

## Builds

Flutter applications can be built for various target platforms. The following sections outline the steps for creating builds for Android and the web.

### Versioning

Before creating a build, it's important to update the version number in the `pubspec.yaml` file. The version number is specified in the format `version: <major>.<minor>.<patch>+<build-number>`.

*   `--build-name`: Corresponds to `<major>.<minor>.<patch>`.
*   `--build-number`: Corresponds to the `+<build-number>`.

These values can be overridden during the build process using the `--build-name` and `--build-number` flags.

### Production Build

A production build is an app that is ready to be deployed to end-users.

#### Android (APK)

To create a production-ready Android APK, run the following command:

```bash
flutter build apk --release
```

The output will be located at `build/app/outputs/flutter-apk/app-release.apk`.

#### Android (App Bundle)

For publishing to the Google Play Store, it is recommended to create an App Bundle.

```bash
flutter build appbundle --release
```

The output will be located at `build/app/outputs/bundle/release/app-release.aab`.


#### Web

To create a production web build, run the following command:

```bash
flutter build web
```

The output will be located in the `build/web` directory.

### Pre-production Build

A pre-production build is used for testing and staging before a full release. These builds are often configured to connect to a staging backend or may include additional debugging tools.

#### Flavoring the Build

To manage different environments like production and pre-production, you can use flavors in Flutter. This involves creating different entry points for your app (e.g., `lib/main_prod.dart` and `lib/main_preprod.dart`) and configuring your build settings accordingly.

#### Android (APK)

To build a pre-production APK, you would typically use a different entry point and specify a unique build name and number:

```bash
flutter build apk --release -t lib/main_preprod.dart --build-name 1.0.0-pre --build-number 1
```

#### Web

For a pre-production web build, you might deploy it to a different subdirectory. The `--base-href` flag is useful for this purpose:

```bash
flutter build web -t lib/main_preprod.dart --base-href /preprod/
```
