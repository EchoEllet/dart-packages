/// Returns the Linux application ID of the current GLib `GApplication`.
///
/// Returns `null` if no default `GApplication` exists or if it does not have an
/// application ID.
///
/// Throws [UnsupportedError] if called on a non-Linux platform.
String? linuxApplicationId() {
  throw UnsupportedError(
    'linuxApplicationId() must not be called on this platform.',
  );
}
