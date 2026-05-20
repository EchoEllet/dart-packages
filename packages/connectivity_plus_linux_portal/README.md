# Linux Portal implementation for `connectivity_plus`

A Linux implementation of [connectivity_plus](https://pub.dev/packages/connectivity_plus) that uses XDG Desktop Portal ([`org.freedesktop.portal.NetworkMonitor`](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.NetworkMonitor.html)) for sandbox compliance (e.g., Flathub/Flatpak).

## Getting Started

Call `ConnectivityPlusLinuxPortalPlugin.registerWith()`
either for all Linux desktops or only under 
certain conditions (i.e., Flatpak detection):

```dart
import 'dart:io';

import 'package:connectivity_plus_linux_portal/connectivity_plus_linux_portal.dart';

void main() {
  if (Platform.isLinux) {
    final isFlatpak =
        Platform.environment.containsKey('FLATPAK_ID') ||
        Platform.environment['container'] == 'flatpak';
    final backend = Platform.environment['CONNECTIVITY_BACKEND'];
    final usePortal = isFlatpak || backend == 'portal';

    if (usePortal) {
      ConnectivityPlusLinuxPortalPlugin.registerWith();
    }
  }
}
```

The `connectivity_plus` plugin will now use the portal when running the Flatpak version of the app:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> main() async {
  final result = await Connectivity().checkConnectivity();
  print(result); // Typically [ConnectivityResult.none] or [ConnectivityResult.other].
}
```

### Flatpak manifest

Pass the environment variable in the Flatpak manifest (optional fallback in case `FLATPAK_ID` env variable was not found):

```yaml
finish-args:
  - "--env=CONNECTIVITY_BACKEND=portal"
```

### Manual testing

```shell
flutter run -d linux --dart-define=CONNECTIVITY_BACKEND=portal
```

## Motivation

Address [upstream issue](https://github.com/fluttercommunity/plus_plugins/issues/1241).

The [default `connectivity_plus` Linux implementation uses `nm`](https://github.com/fluttercommunity/plus_plugins/blob/main/packages/connectivity_plus/connectivity_plus/lib/src/connectivity_plus_linux.dart#L5),
which uses `org.freedesktop.NetworkManager`, which causes:

```console
Unhandled Exception: org.freedesktop.DBus.Error.ServiceUnknown: org.freedesktop.DBus.Error.ServiceUnknown
```

While you you can add (last resort):

```yaml
finish-args:
  - --talk-name=org.freedesktop.NetworkManager
```

This approach is often **discouraged** when submitting an app to Flathub ([example comment](https://github.com/flathub/flathub/pull/8362#discussion_r3097282313)).

This package uses [xdg_desktop_portal](https://pub.dev/packages/xdg_desktop_portal). Both `xdg_desktop_portal` and `nm` uses the [dbus](https://pub.dev/packages/dbus) package.
All three packages are maintained by Canonical.

## Limitations

This package uses [`org.freedesktop.portal.NetworkMonitor`](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.NetworkMonitor.html) instead of [`org.freedesktop.NetworkManager`](https://networkmanager.pages.freedesktop.org/NetworkManager/NetworkManager/spec.html).

As a result, fewer `ConnectivityResult` types are supported (by design for sandbox/privacy reasons):

- No network: `ConnectivityResult.none`
- Connected to a network: `ConnectivityResult.other` (still unknown)
- Captive portal: Assumes `ConnectivityResult.wifi`
- Network is metered: Assumes `ConnectivityResult.mobile`

> [!TIP]
> This limitation is not relevant when only the general connectivity state is required (connected vs disconnected), independent of the underlying transport (e.g., Wifi, Ethernet).

You can use the portal implementation only for the Flatpak version (e.g., via environment variable or argument) and keep the default implementation (as shown in [this section](#getting-started)).

## Acknowledgement

- [@sgehrman](https://github.com/fluttercommunity/plus_plugins/issues/1241#issuecomment-1483770198) for sharing the approach
- [xdg_desktop_portal](https://pub.dev/packages/xdg_desktop_portal) by [Canonical](https://canonical.com/)
