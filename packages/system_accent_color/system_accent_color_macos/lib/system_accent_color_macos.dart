import 'dart:ui';

import 'package:system_accent_color_macos/src/ffi_bindings.g.dart';
import 'package:system_accent_color_platform_interface/system_accent_color_platform_interface.dart';

/// An implementation of [SystemAccentColorPlatform] that depends on
/// [`NSColor.controlAccentColor`](https://developer.apple.com/documentation/AppKit/NSColor/controlAccentColor).
class SystemAccentColorMacOS extends SystemAccentColorPlatform {
  /// Registers this class as the default instance of [SystemAccentColorPlatform].
  static void registerWith() {
    SystemAccentColorPlatform.instance = SystemAccentColorMacOS();
  }

  @override
  Future<Color?> getAccentColor() async {
    final nsColor = NSColor.getControlAccentColor();
    final rgb = nsColor.colorUsingColorSpace(
      NSColorSpace.getDeviceRGBColorSpace(),
    );
    if (rgb == null) {
      return null;
    }
    return _fromNSColor(rgb);
  }

  Color _fromNSColor(NSColor c) {
    return Color.fromARGB(
      (c.alphaComponent * 255).round(),
      (c.redComponent * 255).round(),
      (c.greenComponent * 255).round(),
      (c.blueComponent * 255).round(),
    );
  }
}
