@TestOn('vm && linux')
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:dbus/dbus.dart';
import 'package:freedesktop_secret/freedesktop_secret.dart';
import 'package:freedesktop_secret/src/exceptions.dart';
import 'package:test/test.dart';

/// Used to isolate the secrets created by this test suite.
const baseAttributes = {'xdg:schema': 'com.example.integration-test'};

Map<String, String> testAttributes([
  Map<String, String> attributes = const {},
]) => {...baseAttributes, ...attributes};

/// Integration tests verifying the public behavior of the [FreeDesktopSecret]
/// client against a real Secret Service implementation.
///
/// Requires a running Secret Service implementation.
///
/// Run with:
///   dart test integration_test/client_test.dart
void main() {
  late DBusClient dbusClient;
  late FreeDesktopSecret client;

  Future<void> deleteAllTestSecrets({FreeDesktopSecret? overrideClient}) async {
    final localClient = overrideClient ?? client;

    final attrs = testAttributes();
    await localClient.deleteSecret(
      attributes: attrs,
      duplicateStrategy: .deleteAll,
    );

    if (await localClient.countSecrets(attributes: attrs) != 0) {
      fail(
        'Previously stored secrets must be removed before running the tests',
      );
    }
  }

  setUp(() async {
    dbusClient = DBusClient.session();
    client = FreeDesktopSecret(dbusClientProvider: () => dbusClient);

    await client.initialize();

    await deleteAllTestSecrets();
  });

  tearDown(() async {
    await client.close();
    await dbusClient.close();
  });

  tearDownAll(() async {
    final cleanupClient = FreeDesktopSecret();

    try {
      await cleanupClient.initialize();
      await deleteAllTestSecrets(overrideClient: cleanupClient);
    } finally {
      await cleanupClient.close();
    }
  });

  Future<void> storeSecret({
    required Map<String, String> attributes,
    String secret = '123',
    String label = 'test',
    bool replace = true,
  }) => client.storeSecretText(
    attributes: testAttributes(attributes),
    secret: secret,
    label: label,
    replace: replace,
  );

  Future<void> storeSecretBytes({
    required Map<String, String> attributes,
    required Uint8List secretBytes,
    required String contentType,
    String label = 'test',
    bool replace = true,
  }) => client.storeSecret(
    attributes: testAttributes(attributes),
    secretBytes: secretBytes,
    contentType: contentType,
    label: label,
    replace: replace,
  );

  Future<SecretItem?> lookupSecret({
    required Map<String, String> attributes,
    LookupSecretDuplicateStrategy duplicateStrategy = .throwException,
  }) => client.lookupSecret(
    attributes: testAttributes(attributes),
    duplicateStrategy: duplicateStrategy,
  );

  Future<int> deleteSecret({
    required Map<String, String> attributes,
    DeleteSecretDuplicateStrategy duplicateStrategy = .throwException,
  }) => client.deleteSecret(
    attributes: testAttributes(attributes),
    duplicateStrategy: duplicateStrategy,
  );

  Future<int> countSecrets({required Map<String, String> attributes}) =>
      client.countSecrets(attributes: testAttributes(attributes));

  test('previously closed instance can be reinitialized', () async {
    final attrs = {'type': 'user'};

    expect(await countSecrets(attributes: attrs), 0);

    await storeSecret(
      attributes: attrs,
      secret: 'important-secret',
      label: 'Example',
      replace: true,
    );

    expect(await countSecrets(attributes: attrs), 1);

    await client.close();
    await client.initialize();

    final secret = await lookupSecret(attributes: attrs);

    expect(secret, isNotNull);
    expect(secret!.secretAsText(), 'important-secret');
  });

  test('stored secret can be looked up', () async {
    final attrs = {'id': '1', 'account': '*'};

    await storeSecret(
      attributes: attrs,
      secret: 'my-secret',
      label: 'Integration Test',
      replace: true,
    );

    final secret = await lookupSecret(attributes: attrs);

    expect(secret, isNotNull);
    expect(secret!.secretAsText(), 'my-secret');
    expect(secret.label, 'Integration Test');
    expect(secret.attributes, equalsAttributes(attrs));
  });

  test('stored secrets can be counted', () async {
    final stableAttrs = {'stable': 'key'};

    for (int i = 0; i < 3; i++) {
      await storeSecret(
        attributes: {'id': '$i', ...stableAttrs},
        secret: 'my-secret',
        label: 'Integration Test',
        replace: true,
      );
    }

    expect(await countSecrets(attributes: stableAttrs), 3);
  });

  test('deleted secrets cannot be looked up', () async {
    final attrs = {'id': '9'};

    await storeSecret(
      attributes: attrs,
      secret: 'my-secret',
      label: 'Example',
      replace: true,
    );

    expect(await lookupSecret(attributes: attrs), isNotNull);

    await deleteSecret(attributes: attrs);

    expect(await lookupSecret(attributes: attrs), isNull);
  });

  test('replace: true replaces an existing secret', () async {
    final attrs = {'project': 'quill'};

    await storeSecret(
      attributes: attrs,
      secret: 'old-password',
      label: 'old label',
      replace: true,
    );

    expect(await countSecrets(attributes: attrs), 1);

    await storeSecret(
      attributes: attrs,
      secret: 'new-password',
      label: 'new label',
      replace: true,
    );

    expect(
      await countSecrets(attributes: attrs),
      1,
      reason: 'must not create a new item',
    );

    final newSecret = await lookupSecret(attributes: attrs);

    expect(newSecret, isNotNull);
    expect(newSecret!.secretAsText(), 'new-password');

    // Not asserted intentionally.
    //
    // Secret Service implementations tested so far (KWallet and libsecret via
    // `secret-tool`) preserve the original label when `replace` is true, even
    // though the secret value is updated. The specification does not explicitly
    // define whether the label should be replaced.
    //
    // expect(newSecret.label, 'new label');
  });

  test('replace: false creates a new secret', () async {
    final attrs = {'project': 'quill_native_bridge'};

    await storeSecret(
      attributes: attrs,
      secret: 'old-password',
      label: 'old label',
      replace: false,
    );

    await storeSecret(
      attributes: attrs,
      secret: 'new-password',
      label: 'new label',
      replace: false,
    );

    expect(await countSecrets(attributes: attrs), 2);

    final first = await lookupSecret(
      attributes: attrs,
      duplicateStrategy: .first,
    );
    final last = await lookupSecret(
      attributes: attrs,
      duplicateStrategy: .last,
    );

    expect(first, isNotNull);
    expect(first!.secretAsText(), 'new-password');
    expect(first.label, 'new label');

    expect(last, isNotNull);
    expect(last!.secretAsText(), 'old-password');
    expect(last.label, 'old label');
  });

  test('binary secrets are stored and retrieved unchanged', () async {
    final attrs = {'user': '@username'};

    await storeSecretBytes(
      attributes: attrs,
      secretBytes: Uint8List.fromList([0, 1, 2, 127, 128, 254, 255]),
      contentType: 'application/octet-stream',
    );

    final secret = await lookupSecret(attributes: attrs);

    expect(secret, isNotNull);
    expect(secret!.secretBytes, orderedEquals([0, 1, 2, 127, 128, 254, 255]));
    expect(secret.contentType, 'application/octet-stream');
  });

  test('textual secrets can be stored as bytes', () async {
    // Verifies that textual secrets can be stored via the binary API.
    //
    // This can serve as a workaround for a current `secret-tool lookup` limitation,
    // which only supports secrets with the `text/plain` content type:
    // https://gitlab.gnome.org/GNOME/libsecret/-/work_items/114

    final attrs = {'user': '@new_username'};

    await storeSecretBytes(
      attributes: attrs,
      secretBytes: Uint8List.fromList(utf8.encode('super important secret')),
      contentType: 'text/plain',
    );

    final secret = await lookupSecret(attributes: attrs);

    expect(secret, isNotNull);
    expect(secret!.secretAsText(), 'super important secret');
    expect(secret.contentType, 'text/plain');
  });

  test(
    'lookup throws when multiple secrets match without specifying a duplicate strategy',
    () async {
      final attrs = {'key': 'id'};

      await storeSecret(attributes: attrs, replace: false);
      await storeSecret(attributes: attrs, replace: false);

      expect(await countSecrets(attributes: attrs), 2);

      await expectLater(
        lookupSecret(attributes: attrs),
        throwsA(
          isA<DuplicateSecretException>()
              .having((e) => e.matchCount, 'matchCount', 2)
              .having(
                (e) => e.attributes,
                'attributes',
                equalsAttributes(attrs),
              ),
        ),
      );
    },
  );

  test('lookup of a missing secret returns null', () async {
    expect(await lookupSecret(attributes: {'key': '404'}), isNull);
  });

  test('deleting a missing secret succeeds', () async {
    final attrs = {'key': '404'};

    final deleted = await deleteSecret(attributes: attrs);
    expect(deleted, 0);
  });

  test('counting a missing secret returns zero', () async {
    expect(await countSecrets(attributes: {'key': '404'}), 0);
  });

  test('lookup returns the matching secret', () async {
    await storeSecret(
      attributes: {'user': 'alice'},
      secret: 'alice-secret',
      label: 'Alice',
    );

    await storeSecret(
      attributes: {'user': 'bob'},
      secret: 'bob-secret',
      label: 'Bob',
    );

    final alice = await lookupSecret(attributes: {'user': 'alice'});
    final bob = await lookupSecret(attributes: {'user': 'bob'});

    expect(alice, isNotNull);
    expect(alice!.secretAsText(), 'alice-secret');
    expect(alice.label, 'Alice');
    expect(alice.attributes, equalsAttributes({'user': 'alice'}));

    expect(bob, isNotNull);
    expect(bob!.secretAsText(), 'bob-secret');
    expect(bob.label, 'Bob');
    expect(bob.attributes, equalsAttributes({'user': 'bob'}));
  });

  test('lookup supports partial attribute matching', () async {
    Future<void> store({required String id, required String group}) =>
        storeSecret(attributes: {'id': id, 'group': group});

    await store(id: '1', group: 'a');
    await store(id: '2', group: 'a');

    // Store the same attributes again to verify replacement.
    await store(id: '2', group: 'a');

    await store(id: '3', group: 'a');
    await store(id: '4', group: 'b');
    await store(id: '5', group: 'b');
    await store(id: '6', group: 'c');
    await store(id: '7', group: 'z');

    expect(await countSecrets(attributes: {'group': 'a'}), 3);
    expect(await countSecrets(attributes: {'group': 'b'}), 2);
    expect(await countSecrets(attributes: {'id': '6', 'group': 'b'}), 0);
    expect(await countSecrets(attributes: {'id': '6', 'group': 'c'}), 1);
    expect(await countSecrets(attributes: {'group': 'z'}), 1);
  });

  test('deletes by partial attributes', () async {
    Future<void> store({required String id, required String group}) =>
        storeSecret(attributes: {'id': id, 'group': group});

    await store(group: 'a', id: '1');
    await store(group: 'a', id: '2');
    await store(group: 'b', id: '3');

    await deleteSecret(
      attributes: {'group': 'a'},
      duplicateStrategy: .deleteAll,
    );

    expect(await countSecrets(attributes: {'group': 'a'}), 0);
    expect(await countSecrets(attributes: {'group': 'b'}), 1);

    final remaining = await lookupSecret(attributes: {'group': 'b'});

    expect(remaining, isNotNull);
    expect(remaining!.attributes, equalsAttributes({'id': '3', 'group': 'b'}));

    expect(await lookupSecret(attributes: {'group': 'a'}), isNull);
  });

  test('deletes all matching secrets with the delete-all strategy', () async {
    final attrs = {'id': 'example', 'type': 'account'};
    Future<void> store() => storeSecret(attributes: attrs, replace: false);

    await store();
    await store();
    await store();

    expect(await countSecrets(attributes: attrs), 3);

    // Ensures that at least one item is retrievable before deletion
    expect(
      await lookupSecret(attributes: attrs, duplicateStrategy: .last),
      isNotNull,
    );

    final deletedCount = await deleteSecret(
      attributes: attrs,
      duplicateStrategy: .deleteAll,
    );

    expect(deletedCount, 3);

    expect(await countSecrets(attributes: attrs), 0);
    expect(await lookupSecret(attributes: attrs), isNull);
  });

  test('attribute matching is independent of attribute order', () async {
    await storeSecret(
      attributes: {'a': '1', 'b': '2'},
      secret: 'my-secret',
      label: 'Example',
    );

    final first = await lookupSecret(attributes: {'a': '1', 'b': '2'});

    final second = await lookupSecret(attributes: {'b': '2', 'a': '1'});

    expect(first, isNotNull);
    expect(second, isNotNull);

    expect(second!.secretAsText(), first!.secretAsText());
    expect(second.label, first.label);
    expect(second.attributes, first.attributes);
  });

  test('lookup returns the stored attributes', () async {
    final storedAttrs = {'id': '1', 'group': 'admin', 'account': 'alice'};

    await storeSecret(
      attributes: storedAttrs,
      secret: 'my-secret',
      label: 'Example',
    );

    expect(await countSecrets(attributes: {'id': '1'}), 1);

    final secret = await lookupSecret(attributes: {'id': '1'});

    expect(secret, isNotNull);
    expect(secret!.attributes, equalsAttributes(storedAttrs));
  });

  test('deletes the first matching secret when specified', () async {
    final attrs = {'id': 'example'};

    await storeSecret(
      attributes: attrs,
      secret: 'old',
      label: 'Old',
      replace: false,
    );

    await storeSecret(
      attributes: attrs,
      secret: 'new',
      label: 'New',
      replace: false,
    );

    expect(await countSecrets(attributes: attrs), 2);

    expect(await deleteSecret(attributes: attrs, duplicateStrategy: .first), 1);

    expect(await countSecrets(attributes: attrs), 1);

    final remaining = await lookupSecret(
      attributes: attrs,
      duplicateStrategy: .first,
    );

    expect(remaining, isNotNull);
    expect(remaining!.secretAsText(), 'old');
    expect(remaining.label, 'Old');
  });

  test('deletes the last matching secret when specified', () async {
    final attrs = {'id': 'example'};

    await storeSecret(
      attributes: attrs,
      secret: 'old',
      label: 'Old',
      replace: false,
    );

    await storeSecret(
      attributes: attrs,
      secret: 'new',
      label: 'New',
      replace: false,
    );

    expect(await countSecrets(attributes: attrs), 2);

    expect(await deleteSecret(attributes: attrs, duplicateStrategy: .last), 1);

    expect(await countSecrets(attributes: attrs), 1);

    final remaining = await lookupSecret(
      attributes: attrs,
      duplicateStrategy: .first,
    );

    expect(remaining, isNotNull);
    expect(remaining!.secretAsText(), 'new');
    expect(remaining.label, 'New');
  });

  test(
    'newly stored secret has valid creation and modification timestamps',
    () async {
      final before = now();

      await storeSecret(attributes: {'id': 'timestamps'});

      final after = now();

      final secret = await lookupSecret(attributes: {'id': 'timestamps'});

      expect(secret, isNotNull);

      expect(secret!.created.isBefore(before), isFalse);
      expect(secret.created.isAfter(after), isFalse);

      expect(secret.modified.isBefore(before), isFalse);
      expect(secret.modified.isAfter(after), isFalse);

      expect(secret.created, secret.modified);
    },
  );

  test(
    'replacing a secret preserves the creation timestamp and updates the modification timestamp',
    () async {
      final attrs = {'id': 'timestamps'};

      await storeSecret(attributes: attrs);

      final original = await lookupSecret(attributes: attrs);

      expect(original, isNotNull);

      final beforeUpdate = now();

      await storeSecret(attributes: attrs, replace: true);

      final afterUpdate = now();

      final updated = await lookupSecret(attributes: attrs);

      expect(updated, isNotNull);

      expect(updated!.created, original!.created);

      expect(updated.modified.isBefore(beforeUpdate), isFalse);
      expect(updated.modified.isAfter(afterUpdate), isFalse);

      expect(updated.modified.isBefore(original.modified), isFalse);
    },
  );

  test('attribute matching is case-sensitive', () async {
    await storeSecret(attributes: {'User': 'Alice'});

    expect(await lookupSecret(attributes: {'User': 'Alice'}), isNotNull);

    expect(await lookupSecret(attributes: {'user': 'Alice'}), isNull);

    expect(await lookupSecret(attributes: {'User': 'alice'}), isNull);
  });

  test('stores and retrieves secrets with UTF-8 characters', () async {
    const secret = 'pässwörd 🔐 مرحبا 世界\nline 2\t✓';

    final attrs = {'key': 'utf8-secret'};

    await storeSecret(attributes: attrs, secret: secret);

    final secretItem = await lookupSecret(attributes: attrs);

    expect(secretItem, isNotNull);
    expect(secretItem!.secretAsText(), secret);
  });

  test('operations after client close do not succeed silently', () async {
    final attrs = {'id': 'closed-client'};

    await storeSecret(attributes: attrs, secret: 'my-secret');

    expect(await lookupSecret(attributes: attrs), isNotNull);

    await client.close();

    await expectLater(
      lookupSecret(attributes: attrs),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      countSecrets(attributes: attrs),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      deleteSecret(attributes: attrs),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      storeSecret(attributes: attrs),
      throwsA(isA<StateError>()),
    );
  });
}

Matcher equalsAttributes(Map<String, String> attributes) {
  return equals(testAttributes(attributes));
}

// Secret Service timestamps have second resolution, while `DateTime.now()`
// includes milliseconds and microseconds. Truncate to whole seconds before
// comparing to avoid false negatives.
DateTime truncateToSecond(DateTime value) => DateTime.utc(
  value.year,
  value.month,
  value.day,
  value.hour,
  value.minute,
  value.second,
);

DateTime now() => truncateToSecond(DateTime.now().toUtc());
