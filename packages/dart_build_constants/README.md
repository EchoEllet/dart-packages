# dart_build_constants

Provides convenient constants for Dart's compile-time environment without a dependency on Flutter.

```dart
const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
const bool kProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool kDebugMode = !kReleaseMode && !kProfileMode;
const bool kIsWeb = bool.fromEnvironment('dart.library.js_interop');
const bool kIsWasm = bool.fromEnvironment('dart.tool.dart2wasm');
```

> [!NOTE]
> Copied from: [flutter/flutter/66281ce5206d6af6208deebac9dc06fdd6d5f88b/packages/flutter/foundation/constants.dart](https://github.com/flutter/flutter/blob/66281ce5206d6af6208deebac9dc06fdd6d5f88b/packages/flutter/lib/src/foundation/constants.dart)

The original constants in `flutter/foundation/constants.dart` are Flutter-agnostic. `precisionErrorTolerance` has been removed for a cleaner separation of concerns, since it seems to be a Flutter framework implementation detail, not a Dart compile-time environment constant.

## Motivation

Allowing the use of these Dart constants without any Flutter imports.

With the same API, names, and behavior as Flutter:

```patch
- import 'package:flutter/foundation.dart';
+ import 'package:dart_build_constants.dart/dart_build_constants.dart';
```

Example use cases:

- Server web applications (e.g., Dart Shelf)
- HTTP API clients that handle authentication differently on web than native platforms (e.g., HttpOnly cookies)
- Detects whether the application is in release mode in Dart packages (e.g., [ffi_leak_tracker](https://github.com/halildurmus/win32/blob/main/packages/ffi_leak_tracker/lib/src/utils.dart#L81-L82))
- Disables features that are not supported natively in web browsers
- Different default application state in web or release builds (e.g., to keep using [bloc](https://pub.dev/packages/bloc) without Flutter)

> [!NOTE]
> The names of these Dart constants may change over time in the Flutter framework ([example commit](https://github.com/flutter/flutter/commit/66281ce5206d6af6208deebac9dc06fdd6d5f88b#diff-b05f6d1d251f0e664a774d98e23eeb92b1d0336f76aa5157eaa6bee50d730b40L83) to support WASM). Having a single package makes it easier to keep changes to the underlying Dart environment keys in sync, rather than requiring every project to define and maintain its own constants.

## License

BSD 3-Clause License. See [LICENSE](LICENSE).
