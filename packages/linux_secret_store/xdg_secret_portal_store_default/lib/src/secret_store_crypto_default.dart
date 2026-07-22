import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';

/// Default [SecretStoreCrypto] implementation using HKDF-SHA-256 and
/// XChaCha20-Poly1305.
class SecretStoreCryptoDefault implements SecretStoreCrypto {
  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  Future<SecretKey> _deriveKey(Uint8List masterSecret) {
    return _hkdf.deriveKey(
      secretKey: SecretKey(masterSecret),
      info: utf8.encode('xdg_secret_portal_store'),
    );
  }

  static final _cipher = Xchacha20.poly1305Aead();

  @override
  Future<EncryptedSecretStore> encrypt(
    String plaintext,
    Uint8List masterSecret,
  ) async {
    final secretKey = await _deriveKey(masterSecret);

    final encrypted = await _cipher.encryptString(
      plaintext,
      secretKey: secretKey,
    );

    return EncryptedSecretStore(
      version: 1,
      kdf: 'HKDF-SHA256',
      cipher: 'XChaCha20-Poly1305',
      nonce: base64Encode(encrypted.nonce),
      ciphertext: base64Encode(encrypted.cipherText),
      mac: base64Encode(encrypted.mac.bytes),
    );
  }

  @override
  Future<String> decrypt(
    EncryptedSecretStore store,
    Uint8List masterSecret,
  ) async {
    final secretKey = await _deriveKey(masterSecret);

    final secretBox = SecretBox(
      base64Decode(store.ciphertext),
      nonce: base64Decode(store.nonce),
      mac: Mac(base64Decode(store.mac)),
    );

    return _cipher.decryptString(secretBox, secretKey: secretKey);
  }
}
