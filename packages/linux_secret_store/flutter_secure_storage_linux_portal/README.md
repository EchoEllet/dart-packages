A Linux implementation of [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) using the XDG Desktop [Secret Portal API](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Secret.html) (`org.freedesktop.portal.Secret`).

## Usage

Use this implementation when the application should use the Secret Portal API,
such as when running in a sandboxed environment (e.g., Flatpak or Snap).

```dart
import 'package:flutter_secure_storage_linux_portal/flutter_secure_storage_linux_portal.dart';

FlutterSecureStorageLinuxPortal.registerWith();
```

> [!IMPORTANT]
> `FlutterSecureStorageLinuxPortal.registerWith()` must be explicitly called. Simply adding the package as a dependency is not sufficient.

## Example

The following example uses this implementation when running in Flatpak or Snap.

```dart
import 'dart:io';

import 'package:flutter_secure_storage_linux_portal/flutter_secure_storage_linux_portal.dart';

if (Platform.isLinux) {
  final environment = Platform.environment;

  final isFlatpak =
      environment.containsKey('FLATPAK_ID') ||
      environment['container'] == 'flatpak';
  final isSnap =
      environment.containsKey('SNAP') ||
      environment.containsKey('SNAP_NAME');
  final usePortal = isFlatpak || isSnap;

  if (usePortal) {
    FlutterSecureStorageLinuxPortal.registerWith();
  }
}
```

> [!TIP]
> This is only an example of when to use the implementation. Applications
may choose different conditions based on their environment or requirements.

## File Path

Stores the secrets encrypted in [a file](https://pub.dev/packages/xdg_secret_portal_store#storage-format):

`$XDG_DATA_HOME/$APPLICATION_ID/xdg_secret_portal_store/secrets.json`.

## Cryptography

For [security details](https://pub.dev/packages/xdg_secret_portal_store_default#cryptography).

## Historical Background

This package was originally developed to be part of the `flutter_secure_storage` repository in [#1204](https://github.com/juliansteenbakker/flutter_secure_storage/pull/1204). The PR was not merged, and it was published in a separate repository.

See also: [#1203](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1203)
