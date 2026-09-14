@TestOn('vm && linux')
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_linux_secret_service/flutter_secure_storage_linux_secret_service.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:test/test.dart';

/// Integration tests verifying the public behavior of [FlutterSecureStorage]
/// against a real Secret Service implementation.
///
/// Requires a running Secret Service implementation.
///
/// Run with:
///   dart test integration_test/integration_test.dart
void main() {
  late FlutterSecureStorage storage;

  setUp(() {
    storage = const FlutterSecureStorage();

    final secureStorageImplementation = FlutterSecureStoragePlatform.instance;
    if (secureStorageImplementation is FlutterSecureStorageLinuxSecretService) {
      secureStorageImplementation.applicationIdOverride =
          'app.example.IntegrationTest';
    }
  });

  tearDown(() async {
    await storage.deleteAll();
  });

  test('registers as the default platform interface instance', () {
    expect(
      FlutterSecureStoragePlatform.instance,
      isA<FlutterSecureStorageLinuxSecretService>(),
    );
  });

  test('writes and reads a value', () async {
    await storage.write(key: 'username', value: 'alice');

    expect(await storage.read(key: 'username'), 'alice');
  });

  test('reading a missing key returns null', () async {
    expect(await storage.read(key: 'missing'), isNull);
  });

  test('containsKey reports whether a key exists', () async {
    expect(await storage.containsKey(key: 'username'), isFalse);

    await storage.write(key: 'username', value: 'alice');

    expect(await storage.containsKey(key: 'username'), isTrue);
  });

  test('readAll returns all stored key-value pairs', () async {
    await storage.write(key: 'username', value: 'alice');
    await storage.write(key: 'password', value: 'secret');

    expect(await storage.readAll(), {
      'username': 'alice',
      'password': 'secret',
    });
  });

  test('writing multiple values does not lose existing values', () async {
    await storage.write(key: 'username', value: 'alice');

    await storage.write(key: 'password', value: 'secret');

    expect(await storage.readAll(), {
      'username': 'alice',
      'password': 'secret',
    });
  });

  test('writing an existing key replaces its value', () async {
    await storage.write(key: 'username', value: 'alice');

    await storage.write(key: 'username', value: 'bob');

    expect(await storage.read(key: 'username'), 'bob');

    expect(await storage.readAll(), {'username': 'bob'});
  });

  test('deletes a key without affecting other keys', () async {
    await storage.write(key: 'username', value: 'alice');
    await storage.write(key: 'password', value: 'secret');

    await storage.delete(key: 'username');

    expect(await storage.read(key: 'username'), isNull);
    expect(await storage.read(key: 'password'), 'secret');
  });

  test('deleteAll removes all stored key-value pairs', () async {
    await storage.write(key: 'username', value: 'alice');
    await storage.write(key: 'password', value: 'secret');

    await storage.deleteAll();

    expect(await storage.readAll(), isEmpty);
  });

  test(
    'stored values can be read by a new FlutterSecureStorage instance',
    () async {
      await storage.write(key: 'username', value: 'alice');

      const newStorage = FlutterSecureStorage();

      expect(await newStorage.read(key: 'username'), 'alice');

      await newStorage.deleteAll();
    },
  );

  test('writes and reads empty strings', () async {
    await storage.write(key: 'empty', value: '');

    expect(await storage.read(key: 'empty'), '');
  });

  test('writes and reads UTF-8 values', () async {
    const value = 'pässwörd 🔐 مرحبا 世界';

    await storage.write(key: 'secret', value: value);

    expect(await storage.read(key: 'secret'), value);
  });

  test('writes and reads values containing JSON characters', () async {
    const value = r'{"key":"value","text":"quotes \" and \\ backslashes"}';

    await storage.write(key: 'secret', value: value);

    expect(await storage.read(key: 'secret'), value);
  });

  test('readAll returns an empty map when no values are stored', () async {
    expect(await storage.readAll(), isEmpty);
  });

  test('deleting a missing key succeeds', () async {
    await storage.delete(key: 'missing');

    expect(await storage.readAll(), isEmpty);
  });

  test('deleteAll succeeds when no values are stored', () async {
    await storage.deleteAll();

    expect(await storage.readAll(), isEmpty);
  });

  test('deleting and rewriting a key works', () async {
    await storage.write(key: 'username', value: 'alice');

    await storage.delete(key: 'username');

    expect(await storage.read(key: 'username'), isNull);

    await storage.write(key: 'username', value: 'bob');

    expect(await storage.read(key: 'username'), 'bob');
  });

  test('readAll reflects updated values', () async {
    await storage.write(key: 'username', value: 'alice');
    await storage.write(key: 'password', value: 'old');

    await storage.write(key: 'password', value: 'new');

    expect(await storage.readAll(), {'username': 'alice', 'password': 'new'});
  });
}
