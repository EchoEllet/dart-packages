# system_accent_color

A Flutter plugin to retrieve the current system accent color.

## Supported platforms

Works best on desktop platforms. iOS is unsupported.
Web support is not guaranteed and typically works more reliably when the Flutter web app is installed as a browser app (PWA).

| Platform | Source / API | Notes |
|----------|--------------|------|
| Linux | `org.freedesktop.appearance/accent-color` via [XDG Desktop Portal](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Settings.html) (`org.freedesktop.portal.Settings`) | Independent of GTK theme values such as `@theme_selected_bg_color` |
| macOS | [`NSColor.controlAccentColor`](https://developer.apple.com/documentation/appkit/nscolor/controlaccentcolor) | |
| Windows | [`DwmGetColorizationColor`](https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmgetcolorizationcolor) | |
| Android | [`android.R.attr.colorAccent`](https://developer.android.com/reference/android/R.attr#colorAccent) | Version/OEM dependent. Android 12+ typically reflects user-selected system accent color |
| iOS | Not supported | Always returns `null` |
| Web | [CSS `AccentColor`](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/system-color) via temporary DOM element + computed style | Better support in PWA mode. Behavior varies by browser |

## Usage

```dart
import 'package:system_accent_color/system_accent_color.dart';

final Color? accentColor = await SystemAccentColor().getAccentColor();
```

## Example

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final accentColor = await SystemAccentColor().getAccentColor();
  runApp(MainApp(accentColor: accentColor));
}

class MainApp(final Color? _accentColor) extends StatelessWidget {
  static const Color _fallbackColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    final seed = accentColor ?? _fallbackColor;

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
      ),
      home: ...,
    );
  }
}
```
