import 'dart:io';

import 'package:test/test.dart';
import 'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';

void main() {
  late Directory tempDirectory;
  late File file;
  late SecretStorePersistenceFile persistence;

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync();
    file = File('${tempDirectory.path}/store.json');
    persistence = SecretStorePersistenceFile(file);
  });

  tearDown(() async {
    if (tempDirectory.existsSync()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  const store = EncryptedSecretStore(
    version: 1,
    kdf: 'HKDF-SHA256',
    cipher: 'XChaCha20-Poly1305',
    nonce: 'nonce',
    ciphertext: 'ciphertext',
    mac: 'mac',
  );

  test('read returns null when the file does not exist', () async {
    final result = await persistence.read();

    expect(result, isNull);
  });

  test('write creates the file with the serialized store', () async {
    await persistence.write(store);

    expect(file.existsSync(), isTrue);

    final content = await file.readAsString();

    expect(content, contains('"version":1'));
    expect(content, contains('"cipher":"XChaCha20-Poly1305"'));
  });

  test('read returns the previously written store', () async {
    await persistence.write(store);

    final result = await persistence.read();

    expect(result?.toJson(), store.toJson());
  });

  test('write creates missing parent directories', () async {
    final nestedFile = File('${tempDirectory.path}/nested/store.json');
    final nestedPersistence = SecretStorePersistenceFile(nestedFile);

    await nestedPersistence.write(store);

    expect(nestedFile.existsSync(), isTrue);
  });

  test('read throws when the file contains invalid JSON', () async {
    await file.writeAsString('invalid json');

    expect(() => persistence.read(), throwsA(isA<FormatException>()));
  });
}
