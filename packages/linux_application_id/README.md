# Linux Application ID

This package requires the application to be running under a GLib `GApplication`.
Flutter's default Linux runner satisfies this requirement.
If an alternative Linux embedder that does not use `GApplication` is used,
this package may not work as intended.

It uses a conditional import to avoid breaking web builds.

## Usage

```dart
import 'package:linux_application_id.dart/linux_application_id.dart';

// Must not be called on non-Linux platforms.
print(linuxApplicationId());
```

- Returns `null` if no default `GApplication` exists or if it has no application ID.
- The result is typically non-null with Flutter's default Linux embedder.
- Throws `UnsupportedError` when called on a non-Linux platform (e.g., web, iOS).

## Use case

This library is useful for Dart-based Linux platform implementations, including Flutter plugins and Dart packages.

For Flutter plugins, consider the following pattern:

```dart
import 'package:linux_application_id.dart/linux_application_id.dart';

class SamplePluginLinux extends SamplePluginPlatform {
  static void registerWith() {
    SamplePluginPlatform.instance = SamplePluginLinux();
  }

  /// Overrides the Linux application ID.
  ///
  /// If null, the application ID of the running GLib `GApplication` is used.
  ///
  /// The application ID is used for <PLUGIN_USE_CASE>.
  String? applicationIdOverride;

  String get _applicationId =>
      applicationIdOverride ??
      linuxApplicationId() ??
      (throw UnsupportedError(
        'No Linux application ID is available. This must be called from a running Flutter Linux application.',
      ));
}
```

> [!NOTE]
> Replace `<PLUGIN_USE_CASE>` with a description of how your plugin uses the application ID.

Applications can optionally override it:

```dart
import 'package:sample_plugin_platform_interface/sample_plugin_platform_interface.dart';
import 'package:sample_plugin_linux/sample_plugin_linux.dart';
// ···

final SamplePluginPlatform samplePluginImplementation = SamplePluginPlatform.instance;
if (samplePluginImplementation is SamplePluginLinux) {
  samplePluginImplementation.applicationIdOverride = 'com.example.legacy';
}
```

This is similar to a pattern used by some Flutter plugins (e.g., [`image_picker_android`](https://github.com/flutter/packages/blob/24a3833ea0c602a64154e99d4f1ee9b420c9c714/packages/image_picker/image_picker_android/lib/image_picker_android.dart#L19-L22) and its [README](https://github.com/flutter/packages/tree/24a3833ea0c602a64154e99d4f1ee9b420c9c714/packages/image_picker/image_picker_android#photo-picker)).

> [!TIP]
> Allowing consumers to override the application ID via `applicationIdOverride` not only supports custom Flutter Linux embedders and exceptional cases, but also enables integration tests to run directly in Dart (for FFI-based platform implementations that do not use method channels). This avoids building a native Linux application and starting a Flutter engine during testing, making integration tests significantly faster to run.

## Runtime dependencies

This package dynamically loads `libgio-2.0.so.0` using Dart FFI.

This approach is similar to the [internal implementation used by `package:path_provider_linux`](https://github.com/flutter/packages/blob/af136ccab198bc7dfa25f5fa5ace23fdbcdaadc7/packages/path_provider/path_provider_linux/lib/src/get_application_id_real.dart#L23) for retrieving the application ID.

## Motivation

### Why not [`package_info_plus`](https://pub.dev/packages/package_info_plus)

It performs two file I/O operations (asynchronous), parses a JSON file, assumes
that `data/flutter_assets/version.json` exists, a Flutter-specific file, silently
[falls back to empty strings instead of `null`](https://github.com/fluttercommunity/plus_plugins/blob/f0da4b919cec0aaebbdc8daf8c4475e6bc0ae2ec/packages/package_info_plus/package_info_plus/lib/src/package_info_plus_linux.dart#L24-L29)
if anything fails, adds transitive dependencies that are not relevant to its Linux implementation (e.g.,
[`win32`](https://pub.dev/packages/win32)).

This asset file can be modified or removed at runtime, and in rare cases may be unreadable due to permission issues.

Relevant implementation reference: [`package_info_plus/package_info_plus_linux.dart`](https://github.com/fluttercommunity/plus_plugins/blob/f0da4b919cec0aaebbdc8daf8c4475e6bc0ae2ec/packages/package_info_plus/package_info_plus/lib/src/package_info_plus_linux.dart#L19-L45)

These tradeoffs might be acceptable for applications. `linux_application_id`
is useful for Linux platform implementations and Flutter plugins that need to keep transitive dependencies minimal and stable (e.g., [example use case](https://pub.dev/packages/freedesktop_secret#for-library-authors-do-not-hardcode-the-application-id)). Its smaller scope makes it less prone to breaking changes.

### Why not read the `APPLICATION_ID` C macro

It does not appear to be possible using Dart FFI, and would require native code
and Flutter method channels.

### Why not Flutter method channels

They have some overhead compared to FFI, are Flutter-specific, and are asynchronous.

Some platform implementation packages have been rewritten to use FFI, for
example [`path_provider_foundation`](https://github.com/flutter/packages/pull/10722),
and some plugins now use JNI on Android (e.g.,
[`path_provider_android`](https://github.com/flutter/packages/pull/9770)).

FFI approach is independent of `WidgetsFlutterBinding.ensureInitialized()`.

### Why not code generation or hardcoding

This works well for application packages, but not for published packages that need access to the running Linux application ID.

It would require explicitly passing the application ID as a `String` to the
library, which is not ideal for Flutter plugins that use
`static void registerWith()` to register the platform implementation.
