import 'dart:ui';

import 'package:system_accent_color_platform_interface/system_accent_color_platform_interface.dart';

/// Provides access to the system accent color.
///
/// See [getAccentColor].
class SystemAccentColor {
  static SystemAccentColorPlatform get _platform =>
      SystemAccentColorPlatform.instance;

  /// Returns the operating system's current accent color.
  ///
  /// Returns `null` if the platform does not support accent colors or the
  /// accent color cannot be provided.
  ///
  /// Implementations:
  ///
  /// - Linux: Reads the `org.freedesktop.appearance/accent-color` setting via
  ///   the [`org.freedesktop.portal.Settings`](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Settings.html) portal.
  ///   Independent of GTK's `@theme_selected_bg_color`.
  /// - macOS: [`NSColor.controlAccentColor`](https://developer.apple.com/documentation/AppKit/NSColor/controlAccentColor)
  /// - Windows: [`DwmGetColorizationColor`](https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmgetcolorizationcolor) (Win32)
  /// - Android: Resolves [android.R.attr.colorAccent](https://developer.android.com/reference/android/R.attr#colorAccent).
  ///   Behavior depends on the Android version or OEM.
  ///   On Android 12+, it typically reflects the user-selected system accent color.
  /// - iOS: **unsupported** (always returns `null`)
  /// - Web:
  ///   Creates a temporary `div` with `background-color: AccentColor`,
  ///   reads its computed color, then removes the element.
  ///
  ///   This is implemented on a best-effort basis. Browser support and behavior
  ///   vary, and the returned color may be inaccurate or unavailable.
  ///
  ///   Typically, browsers such as Google Chrome expose a browser-defined
  ///   accent color, unless the Flutter web app is installed as a PWA.
  ///
  Future<Color?> getAccentColor() => _platform.getAccentColor();
}
