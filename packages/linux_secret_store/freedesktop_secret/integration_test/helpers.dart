import 'package:freedesktop_secret/freedesktop_secret.dart';
import 'package:test/test.dart' show fail;

/// Used to isolate the secrets created by this test suite.
const _baseAttributes = {'xdg:schema': 'com.example.integration-test'};

Map<String, String> testAttributes([
  Map<String, String> attributes = const {},
]) => {..._baseAttributes, ...attributes};

Future<void> deleteAllTestSecrets({required FreeDesktopSecret client}) async {
  final attrs = testAttributes();
  await client.deleteSecret(attributes: attrs, duplicateStrategy: .deleteAll);

  if (await client.countSecrets(attributes: attrs) != 0) {
    fail('Previously stored secrets must be removed before running the tests');
  }
}
