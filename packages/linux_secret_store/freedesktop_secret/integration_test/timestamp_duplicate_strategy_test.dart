// ignore_for_file: unreachable_from_main

/// Waits for Secret Service timestamp resolution before the next operation.
///
/// Secret Service timestamps have second resolution. Without this delay,
/// tests that create multiple matching items may receive identical timestamps,
/// causing timestamp-based duplicate strategy assertions to fail even when the
/// implementation behaves correctly.
Future<void> waitForSecretServiceTimestampResolution() async {
  await Future<void>.delayed(const Duration(seconds: 1));
}

void main() {}
