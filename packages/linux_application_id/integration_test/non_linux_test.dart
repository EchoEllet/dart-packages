@TestOn('vm && !linux')
library;

import 'package:linux_application_id/linux_application_id.dart';
import 'package:test/test.dart';

/// Test verifying the behavior of [linuxApplicationId] on non-Linux platforms.
///
/// Run with:
///   dart test integration_test/non_linux_test.dart
void main() {
  test('throws on non-Linux platforms', () {
    expect(() => linuxApplicationId(), throwsA(isA<UnsupportedError>()));
  });
}
