# system_accent_color_platform_interface

A common platform interface for the [`system_accent_color`][1] plugin.

This interface allows platform-specific implementations of the `system_accent_color`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `system_accent_color`, extend
[`SystemAccentColorPlatform`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`SystemAccentColorPlatform` by calling
`SystemAccentColorPlatform.instance = ...;`.

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: ../system_accent_color
[2]: lib/system_accent_color_platform_interface.dart
