import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

final class GApplication extends Opaque {}

typedef _GApplicationGetDefault = Pointer<GApplication> Function();
typedef _GApplicationGetApplicationId =
    Pointer<Utf8> Function(Pointer<GApplication>);

DynamicLibrary? _gio;

_GApplicationGetDefault? _gApplicationGetDefault;
_GApplicationGetApplicationId? _gApplicationGetApplicationId;

void _initialize() {
  final library = _gio ??= DynamicLibrary.open('libgio-2.0.so.0');

  _gApplicationGetDefault ??= library
      .lookupFunction<_GApplicationGetDefault, _GApplicationGetDefault>(
        'g_application_get_default',
      );

  _gApplicationGetApplicationId ??= library
      .lookupFunction<
        _GApplicationGetApplicationId,
        _GApplicationGetApplicationId
      >('g_application_get_application_id');
}

/// Returns the Linux application ID of the current GLib `GApplication`.
///
/// Returns `null` if no default `GApplication` exists or if it does not have an
/// application ID.
///
/// Throws [UnsupportedError] if called on a non-Linux platform.
String? linuxApplicationId() {
  if (!Platform.isLinux) {
    throw UnsupportedError('linuxApplicationId() is only supported on Linux.');
  }

  _initialize();

  final app = _gApplicationGetDefault!();
  if (app == nullptr) {
    return null;
  }

  final id = _gApplicationGetApplicationId!(app);
  if (id == nullptr) {
    return null;
  }

  return id.toDartString();
}
