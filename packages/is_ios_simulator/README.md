# iOS simulator detection

```dart
import 'package:is_ios_simulator/is_ios_simulator.dart';

final result = await isIosSimulator();
print(result);
```

Alternative API (used internally by the top-level `isIosSimulator` function):

```dart
final detection = IosSimulatorDetection();
final result = await detection.isIosSimulator();

print(result);
```

Uses conditional imports to avoid breaking web builds and returns `false` on non-iOS platforms.

## Motivation

Existing packages such as [`device_info_plus`](https://pub.dev/packages/device_info_plus) provide broad device info, introducing additional transitive dependencies (e.g., [`win32`](https://pub.dev/packages/win32), [`win32_registry`](https://pub.dev/packages/win32_registry)) when only iOS simulator detection is required.

Unused dependencies and/or code introduce additional surface area and maintenance overhead in the long term.

Useful for published `pub.dev` packages that may want to detect an iOS simulator while adding a single, tiny transitive dependency.

## Swift Implementation

```swift
#if targetEnvironment(simulator)
    return true
#else
    return false
#endif
```
