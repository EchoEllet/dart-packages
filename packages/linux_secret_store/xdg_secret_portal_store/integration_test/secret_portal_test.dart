@TestOn('vm && linux')
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';
import 'package:xdg_directories/xdg_directories.dart';
import 'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';
import 'package:xdg_secret_portal_store_default/xdg_secret_portal_store_default.dart';

/// Integration tests verifying the public behavior of the
/// [XdgSecretPortalStore] against a real Secret Portal implementation.
///
/// Requires a running Secret Portal implementation.
///
/// Run with:
///   dart test integration_test/secret_portal_test.dart
void main() {
  late File storeFile;

  Future<void> deleteStoreFile() async {
    if (storeFile.existsSync()) {
      await storeFile.delete();
    }
  }

  late XdgDesktopPortalClient client;
  late XdgSecretPortalStore store;

  XdgSecretPortalStore createStore({
    required MasterSecretRetriever masterSecretRetriever,
    required SecretStorePersistence persistence,
  }) => XdgSecretPortalStore(
    masterSecretRetriever: client.secret.retrieveSecret,
    persistence: SecretStorePersistenceFile(storeFile),
    crypto: SecretStoreCryptoDefault(),
  );

  setUp(() async {
    storeFile = File(
      '${dataHome.path}/org.example.xdg_secret_portal_store_example/xdg_secret_portal_store/secrets.json',
    );

    await deleteStoreFile();

    client = XdgDesktopPortalClient();
    store = createStore(
      masterSecretRetriever: client.secret.retrieveSecret,
      persistence: SecretStorePersistenceFile(storeFile),
    );

    await store.loadMasterSecret();
  });

  tearDown(() async {
    await client.close();
    store.clearMasterSecret();
  });

  tearDownAll(() async {
    await deleteStoreFile();
  });

  test('returns an empty map when no secret store exists', () async {
    expect(await store.read(), isEmpty);
  });

  test('writes and reads secrets', () async {
    final secrets = {'password': '123', 'token': 'abc'};

    await store.write(secrets);

    expect(await store.read(), equals(secrets));
  });

  test('overwrites previously stored secrets', () async {
    await store.write({'password': '123'});
    await store.write({'password': '456'});

    expect(await store.read(), equals({'password': '456'}));
  });

  test('persists secrets across store instances', () async {
    await store.write({'password': '123'});

    final anotherStore = createStore(
      masterSecretRetriever: client.secret.retrieveSecret,
      persistence: SecretStorePersistenceFile(storeFile),
    );

    await anotherStore.loadMasterSecret();

    expect(await anotherStore.read(), equals({'password': '123'}));

    anotherStore.clearMasterSecret();
  });

  test('supports empty secret maps', () async {
    await store.write({});

    expect(await store.read(), isEmpty);
  });

  test('overwrites existing secrets with an empty map', () async {
    await store.write({'password': '123'});

    expect(await store.read(), {'password': '123'});

    await store.write({});

    expect(await store.read(), isEmpty);
  });

  test('writes and reads UTF-8 secrets', () async {
    const secrets = {'password': 'pässwörd 🔐 مرحبا 世界\nline 2\t✓'};

    await store.write(secrets);

    expect(await store.read(), equals(secrets));
  });

  test('supports multiple secrets', () async {
    const secrets = {'password': '123', 'token': 'abc', 'username': 'john'};

    await store.write(secrets);

    expect(await store.read(), equals(secrets));
  });

  test('can reload the master secret after clearing it', () async {
    await store.write({'password': '123'});

    store.clearMasterSecret();
    await store.loadMasterSecret();

    expect(await store.read(), equals({'password': '123'}));
  });

  test('throws if the master secret has not been loaded', () async {
    final client = XdgDesktopPortalClient();
    addTearDown(client.close);

    final store = createStore(
      masterSecretRetriever: client.secret.retrieveSecret,
      persistence: SecretStorePersistenceFile(storeFile),
    );

    await expectLater(store.read(), throwsStateError);

    await expectLater(store.write({'password': '123'}), throwsStateError);
  });

  test('throws when the secret store is corrupted', () async {
    await store.write({'password': '123'});

    await storeFile.writeAsString('not valid json');

    await expectLater(store.read(), throwsA(isA<FormatException>()));
  });
}
