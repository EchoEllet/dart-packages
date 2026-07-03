import 'dart:ui';

import 'package:jni_flutter/jni_flutter.dart';
import 'package:system_accent_color_android/src/android_bindings.g.dart';
import 'package:system_accent_color_platform_interface/system_accent_color_platform_interface.dart';

class SystemAccentColorAndroid extends SystemAccentColorPlatform {
  /// Registers this class as the default instance of [SystemAccentColorPlatform].
  static void registerWith() {
    SystemAccentColorPlatform.instance = SystemAccentColorAndroid();
  }

  @override
  Future<Color?> getAccentColor() async {
    final context = androidApplicationContext as Context;

    final typedValue = TypedValue();
    final theme = context.theme;

    try {
      if (theme == null) {
        return null;
      }
      final resolved = theme.resolveAttribute(
        R$attr.colorAccent,
        typedValue,
        true,
      );
      if (!resolved) {
        return null;
      }
      return Color(typedValue.data);
    } finally {
      typedValue.release();
      theme?.release();
    }
  }
}
