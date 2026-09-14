@TestOn('vm && linux')
library;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_linux_secret_service/flutter_secure_storage_linux_secret_service.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:freedesktop_secret/freedesktop_secret.dart';
import 'package:test/test.dart';

/// Integration tests verifying automatic migration of legacy
/// [FlutterSecureStorage] data against a real Secret Service implementation.
///
/// Legacy data is created with an invalid `xdg:schema` attribute to verify
/// that it is automatically migrated to the current format.
///
/// Issue details: https://github.com/juliansteenbakker/flutter_secure_storage/issues/1181
///
/// Requires a running Secret Service implementation.
///
/// Run with:
///   dart test integration_test/migration_test.dart
void main() {
  late SecretServiceClient client;
  late FlutterSecureStorage storage;
  late FlutterSecureStorageLinuxSecretService storageImplementation;

  setUp(() async {
    client = SecretServiceClient();
    await client.initialize();

    await _deleteAllTestSecrets(client: client);

    storage = const FlutterSecureStorage();

    storageImplementation = FlutterSecureStorageLinuxSecretService();
    storageImplementation.applicationIdOverride = _testAppId;
    storageImplementation.migrateLegacyData = true;
    storageImplementation.deleteLegacyData = false;

    FlutterSecureStoragePlatform.instance = storageImplementation;
  });

  tearDown(() async {
    await client.close();
  });

  tearDownAll(() async {
    final cleanupClient = SecretServiceClient();

    try {
      await cleanupClient.initialize();
      await _deleteAllTestSecrets(client: cleanupClient);
    } finally {
      await cleanupClient.close();
    }
  });

  test('automatically migrates legacy data', () async {
    final values = {'username': 'alice', 'password': 'secret'};

    await _storeLegacySecret(client: client, values: values);

    expect(await storage.readAll(), values);

    final migratedSecret = await client.lookupSecret(
      attributes: _migratedAttributes,
      duplicateStrategy: .newestCreated,
    );

    expect(migratedSecret, isNotNull);
    expect(migratedSecret!.secretAsText(), jsonEncode(values));
  });

  test(
    'skips legacy data migration when current-format data already exists',
    () async {
      await _storeLegacySecret(client: client, values: {'username': 'legacy'});

      await _storeMigratedSecret(
        client: client,
        values: {'username': 'current'},
      );

      expect(await storage.readAll(), {'username': 'current'});

      final migratedSecret = await client.lookupSecret(
        attributes: _migratedAttributes,
        duplicateStrategy: .newestCreated,
      );

      expect(migratedSecret, isNotNull);
      expect(
        migratedSecret!.secretAsText(),
        jsonEncode({'username': 'current'}),
      );
    },
  );

  test('preserves legacy data when deleteLegacyData = false', () async {
    storageImplementation.deleteLegacyData = false;

    final values = {'username': 'alice'};

    await _storeLegacySecret(client: client, values: values);
    expect(await storage.readAll(), values);

    final migratedSecret = await client.lookupSecret(
      attributes: _migratedAttributes,
      duplicateStrategy: .newestCreated,
    );
    expect(migratedSecret, isNotNull);
    expect(migratedSecret!.secretAsText(), jsonEncode(values));

    final legacySecret = await client.lookupSecret(
      attributes: _legacyAttributes,
      duplicateStrategy: .newestCreated,
    );
    expect(legacySecret, isNotNull);
    expect(legacySecret!.secretAsText(), jsonEncode(values));
  });

  test(
    'deletes legacy data after successful migration when deleteLegacyData = true',
    () async {
      storageImplementation.deleteLegacyData = true;

      final values = {'username': 'alice', 'password': 'secret'};

      await _storeLegacySecret(client: client, values: values);
      expect(await storage.readAll(), values);

      final migratedSecret = await client.lookupSecret(
        attributes: _migratedAttributes,
        duplicateStrategy: .newestCreated,
      );
      expect(migratedSecret, isNotNull);
      expect(migratedSecret!.secretAsText(), jsonEncode(values));

      final legacySecret = await client.lookupSecret(
        attributes: _legacyAttributes,
        duplicateStrategy: .newestCreated,
      );
      expect(legacySecret, isNull);
    },
  );

  test('does not migrate legacy data when migration is disabled', () async {
    storageImplementation.migrateLegacyData = false;

    final values = {'username': 'alice', 'password': 'secret'};

    await _storeLegacySecret(client: client, values: values);

    expect(await storage.readAll(), isEmpty);

    final migratedSecret = await client.lookupSecret(
      attributes: _migratedAttributes,
      duplicateStrategy: .newestCreated,
    );
    expect(migratedSecret, isNull);

    final legacySecret = await client.lookupSecret(
      attributes: _legacyAttributes,
      duplicateStrategy: .newestCreated,
    );
    expect(legacySecret, isNotNull);
    expect(legacySecret!.secretAsText(), jsonEncode(values));
  });
}

const _testAppId = 'app.example.IntegrationTest';
const _legacyAttributes = {
  'account': '$_testAppId.secureStorage',
  // Intentionally invalid legacy value.
  'xdg:schema': '9',
};
const _migratedAttributes = {
  'account': '$_testAppId.secureStorage',
  'xdg:schema': '$_testAppId/FlutterSecureStorage',
};

Future<void> _storeSecret({
  required SecretServiceClient client,
  required Map<String, String> attributes,
  required Map<String, String> values,
}) => client.storeSecretText(
  attributes: attributes,
  label: '$_testAppId/FlutterSecureStorage',
  secret: jsonEncode(values),
  replace: true,
);

Future<void> _storeLegacySecret({
  required SecretServiceClient client,
  required Map<String, String> values,
}) =>
    _storeSecret(client: client, attributes: _legacyAttributes, values: values);

Future<void> _storeMigratedSecret({
  required SecretServiceClient client,
  required Map<String, String> values,
}) => _storeSecret(
  client: client,
  attributes: _migratedAttributes,
  values: values,
);

Future<void> _deleteAllTestSecrets({
  required SecretServiceClient client,
}) async {
  await client.deleteSecret(
    attributes: _legacyAttributes,
    duplicateStrategy: .deleteAll,
  );

  await client.deleteSecret(
    attributes: _migratedAttributes,
    duplicateStrategy: .deleteAll,
  );

  if (await client.countSecrets(attributes: _legacyAttributes) != 0) {
    fail(
      'Previously stored legacy secrets must be removed before running the tests',
    );
  }

  if (await client.countSecrets(attributes: _migratedAttributes) != 0) {
    fail(
      'Previously stored migrated secrets must be removed before running the tests',
    );
  }
}
