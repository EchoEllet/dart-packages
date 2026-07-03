import 'dart:ui' show Color;

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of `system_accent_color` must implement.
///
/// Platform implementations should extend this class rather than implement it
/// as newly added methods are not considered to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [SystemAccentColorPlatform] methods.
///
/// See also:
///
/// - [Flutter #127396](https://github.com/flutter/flutter/issues/127396)
/// - [plugin_platform_interface](https://pub.dev/packages/plugin_platform_interface#a-note-about-base)
abstract class SystemAccentColorPlatform extends PlatformInterface {
  SystemAccentColorPlatform() : super(token: _token);

  static final Object _token = Object();

  static SystemAccentColorPlatform _instance = _PlaceholderImplementation();

  /// The default instance of [SystemAccentColorPlatform] to use.
  ///
  /// Defaults to [_PlaceholderImplementation].
  static SystemAccentColorPlatform get instance => _instance;

  /// Platform-specific implementations should set this to their own
  /// platform-specific class that extends [SystemAccentColorPlatform] when they
  /// register themselves.
  static set instance(SystemAccentColorPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Returns the operating system's current accent color.
  ///
  /// Returns `null` if the platform does not support accent colors or the
  /// accent color cannot be provided.
  Future<Color?> getAccentColor() =>
      throw UnimplementedError('getAccentColor() has not been implemented.');
}

/// A default implementation that throws an error if a method is not implemented.
/// This will be overridden by the platform implementation.
class _PlaceholderImplementation extends SystemAccentColorPlatform {}
