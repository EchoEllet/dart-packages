import 'dart:ui';

import 'package:flutter_web_plugins/flutter_web_plugins.dart' show Registrar;
import 'package:system_accent_color_platform_interface/system_accent_color_platform_interface.dart';
import 'package:web/web.dart';

class SystemAccentColorWeb extends SystemAccentColorPlatform {
  /// Registers this class as the default instance of [SystemAccentColorPlatform].
  static void registerWith(Registrar registrar) {
    SystemAccentColorPlatform.instance = SystemAccentColorWeb();
  }

  @override
  Future<Color?> getAccentColor() async {
    final body = document.body;
    if (body == null) {
      return null;
    }

    final el = document.createElement('div') as HTMLDivElement;
    try {
      // `display: none` is avoided, as some browsers may not compute the
      // resolved `background-color` for non-rendered elements.
      el.style
        ..position = 'fixed'
        ..left = '-9999px'
        ..top = '-9999px'
        ..backgroundColor = 'AccentColor';

      body.appendChild(el);

      final cssColor = window.getComputedStyle(el).backgroundColor;

      if (cssColor.trim().isEmpty ||
          cssColor == 'transparent' ||
          cssColor == 'rgba(0, 0, 0, 0)') {
        return null;
      }

      return _parseCssColor(cssColor);
    } finally {
      el.remove();
    }
  }

  Color? _parseCssColor(String cssColor) {
    if (!cssColor.startsWith('rgba(') && !cssColor.startsWith('rgb(')) {
      return null;
    }

    final values = cssColor
        .substring(cssColor.indexOf('(') + 1, cssColor.length - 1)
        .split(',');

    if (values.length < 3) {
      return null;
    }

    final r = int.tryParse(values[0].trim());
    final g = int.tryParse(values[1].trim());
    final b = int.tryParse(values[2].trim());

    if (r == null || g == null || b == null) {
      return null;
    }

    var a = 255;

    if (values.length == 4) {
      final alpha = double.tryParse(values[3].trim());
      if (alpha == null) {
        return null;
      }
      a = (alpha.clamp(0.0, 1.0) * 255).round();
    }
    return Color.fromARGB(a, r, g, b);
  }
}
