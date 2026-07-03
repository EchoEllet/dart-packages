import 'dart:ui';

import 'package:system_accent_color_platform_interface/system_accent_color_platform_interface.dart';

class SystemAccentColorIOS extends SystemAccentColorPlatform {
  /// Registers this class as the default instance of [SystemAccentColorPlatform].
  static void registerWith() {
    SystemAccentColorPlatform.instance = SystemAccentColorIOS();
  }

  @override
  Future<Color?> getAccentColor() async {
    return null;
  }
}
