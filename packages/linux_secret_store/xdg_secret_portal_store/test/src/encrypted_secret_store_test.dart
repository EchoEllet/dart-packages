import 'package:test/test.dart';
import 'package:xdg_secret_portal_store/src/encrypted_secret_store.dart';

void main() {
  const store = EncryptedSecretStore(
    version: 1,
    kdf: 'HKDF-SHA256',
    cipher: 'XChaCha20-Poly1305',
    nonce: 'nonce',
    ciphertext: 'ciphertext',
    mac: 'mac',
  );

  test('toJson returns the serialized representation', () {
    expect(store.toJson(), {
      'version': 1,
      'kdf': 'HKDF-SHA256',
      'cipher': 'XChaCha20-Poly1305',
      'nonce': 'nonce',
      'ciphertext': 'ciphertext',
      'mac': 'mac',
    });
  });

  test('fromJson creates a store from the serialized representation', () {
    final result = EncryptedSecretStore.fromJson({
      'version': 1,
      'kdf': 'HKDF-SHA256',
      'cipher': 'XChaCha20-Poly1305',
      'nonce': 'nonce',
      'ciphertext': 'ciphertext',
      'mac': 'mac',
    });

    expect(result.version, store.version);
    expect(result.kdf, store.kdf);
    expect(result.cipher, store.cipher);
    expect(result.nonce, store.nonce);
    expect(result.ciphertext, store.ciphertext);
    expect(result.mac, store.mac);
  });

  test('toJson and fromJson preserve all fields', () {
    final result = EncryptedSecretStore.fromJson(store.toJson());

    expect(result.version, store.version);
    expect(result.kdf, store.kdf);
    expect(result.cipher, store.cipher);
    expect(result.nonce, store.nonce);
    expect(result.ciphertext, store.ciphertext);
    expect(result.mac, store.mac);
  });
}
