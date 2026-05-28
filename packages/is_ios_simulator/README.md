# iOS simulator detection

```dart
import 'package:is_ios_simulator/is_ios_simulator.dart';

void main() async {
    final result = await isIosSimulator();
    print(result);
}
```

Alternative API (consumed by the top-level `isIosSimulator` function):

```dart
final detection = IosSimulatorDetection();
final result = await result.isIosSimulator();
print(result);
```

## Why reinvent the wheel?

Packages like [device_info_plus](https://pub.dev/packages/device_info_plus) provide broad device info, introducing unnecessary transitive dependencies (e.g., [win32](https://pub.dev/packages/win32), [win32_registry](https://pub.dev/packages/win32_registry)) when only iOS simulator detection is required.

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
