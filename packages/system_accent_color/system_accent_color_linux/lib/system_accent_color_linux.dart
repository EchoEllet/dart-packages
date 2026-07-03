import 'dart:ui';

// ignore: depend_on_referenced_packages
import 'package:dbus/dbus.dart' show DBusValue;
import 'package:system_accent_color_platform_interface/system_accent_color_platform_interface.dart';
import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';

typedef XdgDesktopPortalClientProvider = XdgDesktopPortalClient Function();

/// An implementation of [SystemAccentColorPlatform] that depends on
/// [`org.freedesktop.portal.Settings`](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Settings.html).
///
/// Reads the `org.freedesktop.appearance/accent-color` from the settings.
///
/// If [_portalClientProvider] is non-null, the
/// [XdgDesktopPortalClient] returned by the callback is **not closed** by this
/// class, and the caller is responsible for calling
/// [XdgDesktopPortalClient.close].
class SystemAccentColorLinux extends SystemAccentColorPlatform {
  SystemAccentColorLinux({
    required XdgDesktopPortalClientProvider? portalClientProvider,
  }) : _portalClientProvider = portalClientProvider;

  final XdgDesktopPortalClientProvider? _portalClientProvider;

  /// Registers this class as the default instance of [SystemAccentColorPlatform].
  static void registerWith() {
    SystemAccentColorPlatform.instance = SystemAccentColorLinux(
      portalClientProvider: null,
    );
  }

  XdgDesktopPortalClient _createPortal() {
    return _portalClientProvider?.call() ?? XdgDesktopPortalClient();
  }

  static const String _namespace = 'org.freedesktop.appearance';
  static const String _key = 'accent-color';

  @override
  Future<Color?> getAccentColor() async {
    final client = _createPortal();
    try {
      final result = await client.settings.read(_namespace, _key);
      return _colorFromDBusAccent(result.asVariant().asStruct());
    } on Exception {
      return null;
    } finally {
      if (_portalClientProvider == null) {
        await client.close();
      }
    }
  }

  Color _colorFromDBusAccent(List<DBusValue> values) {
    final r = (values[0].asDouble() * 255).round();
    final g = (values[1].asDouble() * 255).round();
    final b = (values[2].asDouble() * 255).round();

    return Color.fromARGB(255, r, g, b);
  }
}
