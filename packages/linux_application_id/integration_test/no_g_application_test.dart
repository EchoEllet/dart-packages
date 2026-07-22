@TestOn('vm && linux')
library;

import 'package:linux_application_id/linux_application_id.dart';
import 'package:test/test.dart';

/// Test verifying the behavior of [linuxApplicationId] when no default
/// `GApplication` exists.
///
/// This test runs outside a Flutter application.
///
/// Run with:
///   dart test integration_test/no_g_application_test.dart
void main() {
  test('returns null when no default GApplication exists', () {
    expect(linuxApplicationId(), null);
  });
}
