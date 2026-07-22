@TestOn('vm && linux')
library;

import 'package:linux_application_id/linux_application_id.dart';
import 'package:test/test.dart';

/// Test verifying the behavior of [linuxApplicationId] when running inside
/// a Flutter Linux app.
///
/// Run with:
///   flutter test integration_test/flutter_linux_test.dart -d linux
void main() {
  test('returns application ID on Flutter Linux', () {
    // Must match the APPLICATION_ID defined in CMakeLists.txt.
    const expectedLinuxAppId = 'com.example.example';

    expect(linuxApplicationId(), expectedLinuxAppId);
  });
}
