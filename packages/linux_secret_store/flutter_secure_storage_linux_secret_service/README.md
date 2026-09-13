# flutter_secure_storage_linux_secret_service

A Linux implementation of the [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) plugin using the Secret Service API ([`org.freedesktop.secrets`](https://specifications.freedesktop.org/secret-service/latest-single/)).

See also [`package:freedesktop_secret`](https://pub.dev/packages/freedesktop_secret), which provides the underlying pure Dart implementation of the Secret Service API used by this package.

## Features

- Pure Dart implementation using D-Bus directly.
- Does not require additional system packages to build or run the application (e.g., `libsecret-1-0` or `libsecret-1-dev` on Ubuntu).
- Uses the standard Secret Service API, which is the primary API used by GNOME libsecret, making it possible to retain compatibility with secrets stored by [`flutter_secure_storage_linux`](https://pub.dev/packages/flutter_secure_storage_linux).
- Handles prompts, unlocking the default collection ([also known](https://specifications.freedesktop.org/secret-service/latest-single/#id-1.2.4) as a keyring or wallet) and items when needed.
- Automatically creates the default collection when it does not exist (e.g., on fresh Linux installations).

## Requirements

These requirements are typically already satisfied by default on most Linux desktop environments.

- A Linux operating system with D-Bus support.
- A running Secret Service implementation (e.g., GNOME Keyring, KDE Wallet or another implementation of the `org.freedesktop.secrets` D-Bus service).

## Usage

Add the package as a dependency in the app's `pubspec.yaml`:

```shell
flutter pub add flutter_secure_storage_linux_secret_service
```

> [!TIP]
> Adding this package automatically registers this implementation and overrides `flutter_secure_storage_linux` (the endorsed implementation of `flutter_secure_storage`). No explicit imports are required.

## Legacy data migration

Older versions of `flutter_secure_storage_linux` had [a historical bug](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1181) that caused the `xdg:schema` attribute to be populated incorrectly.

`flutter_secure_storage_linux` was updated
in [4.0.0-beta.1](https://pub.dev/packages/flutter_secure_storage_linux/versions/4.0.0-beta.1/changelog) to fix this issue and migrate data affected by it. See [the relevant PR](https://github.com/juliansteenbakker/flutter_secure_storage/pull/1249) for details.

This implementation also automatically migrates the old data when appropriate.

The old secrets are not automatically deleted by default to avoid destructive changes, consistent with the behavior of `flutter_secure_storage_linux`, which leaves legacy items in place during migration ([the relevant code](https://github.com/juliansteenbakker/flutter_secure_storage/blob/fe7232b194ed7ab815c8fda59997fccc840844f4/flutter_secure_storage_linux/linux/include/Secret.hpp#L312-L313)).

To opt in to deleting the old data:

```dart
import 'package:flutter_secure_storage_linux_secret_service/flutter_secure_storage_linux_secret_service.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
// ···

final secureStorageImplementation = FlutterSecureStoragePlatform.instance;
if (secureStorageImplementation is FlutterSecureStorageLinuxSecretService) {
  secureStorageImplementation.deleteLegacyData = true;
}
```

To opt out of migrating the old data:

```dart
// Opting out of migration for newer apps avoids an additional lookup.
secureStorageImplementation.migrateLegacyData = false;
```

## Historical Background

This implementation was originally developed as a complete rewrite of `flutter_secure_storage_linux` in [#1182](https://github.com/juliansteenbakker/flutter_secure_storage/pull/1182). The PR was not merged, and the implementation was subsequently extracted into this separate package.
