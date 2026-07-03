import 'dart:ffi';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:system_accent_color_platform_interface/system_accent_color_platform_interface.dart';
import 'package:win32/win32.dart';

/// An implementation of [SystemAccentColorPlatform] that depends on
/// [`DwmGetColorizationColor`](https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmgetcolorizationcolor).
class SystemAccentColorWindows extends SystemAccentColorPlatform {
  /// Registers this class as the default instance of [SystemAccentColorPlatform].
  static void registerWith() {
    SystemAccentColorPlatform.instance = SystemAccentColorWindows();
  }

  @override
  Future<Color?> getAccentColor() async {
    final colorPtr = calloc<Uint32>();
    final opaquePtr = calloc<Int32>();

    try {
      DwmGetColorizationColor(colorPtr, opaquePtr);

      return Color(colorPtr.value);
    } on WindowsException {
      return null;
    } finally {
      calloc.free(colorPtr);
      calloc.free(opaquePtr);
    }
  }
}
