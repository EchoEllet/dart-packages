# Linux Application ID

This package requires the application to be running under a GLib `GApplication`.
Flutter's default Linux runner satisfies this requirement.
If an alternative Linux embedder that does not use `GApplication` is used,
this package may not work as intended.

It uses a conditional import to avoid breaking web builds.

## Usage

```dart
import 'package:linux_application_id.dart/linux_application_id.dart';

print(linuxApplicationId());
```

## Motivation

### Why not [`package_info_plus`](https://pub.dev/packages/package_info_plus)

It performs two file I/O operations (asynchronous), parses a JSON file, assumes
that `data/flutter_assets/version.json` exists, a Flutter-specific file, silently
[falls back to empty strings instead of `null`](https://github.com/fluttercommunity/plus_plugins/blob/f0da4b919cec0aaebbdc8daf8c4475e6bc0ae2ec/packages/package_info_plus/package_info_plus/lib/src/package_info_plus_linux.dart#L24-L29)
if parsing fails, and requires many dependencies (e.g.,
[`win32`](https://pub.dev/packages/win32)).

A lot of overhead, failure points, and dependencies for obtaining the Linux
application ID.

[Source code](https://github.com/fluttercommunity/plus_plugins/blob/f0da4b919cec0aaebbdc8daf8c4475e6bc0ae2ec/packages/package_info_plus/package_info_plus/lib/src/package_info_plus_linux.dart#L35-L45).

### Why not read the `APPLICATION_ID` C macro

It does not appear to be possible using Dart FFI, and would require native code
and Flutter method channels.

### Why not Flutter method channels

They have some overhead compared to FFI and are Flutter specific.

Many platform implementation packages have been rewritten to use FFI, for
example [`path_provider_foundation`](https://github.com/flutter/packages/pull/10722),
and some plugins now use JNI on Android (e.g.,
[`path_provider_android`](https://github.com/flutter/packages/pull/9770)).

### Why not code generation or hardcoding

This works well for application packages, but not for published packages that need access to the running Linux application ID.

It would require explicitly passing the application ID as a `String` to the
library, which is not ideal for Flutter plugins that use
`static void registerWith()` to register the platform implementation.
