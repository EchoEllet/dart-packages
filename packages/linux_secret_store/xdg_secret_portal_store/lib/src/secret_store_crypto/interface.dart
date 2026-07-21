import 'dart:typed_data';

import 'package:xdg_secret_portal_store/src/encrypted_secret_store.dart';

/// Defines encryption and decryption operations for the secret store.
///
/// The [masterSecret] is provided by the XDG Desktop Portal Secret API and is
/// used by implementations to derive or access the encryption key.
abstract interface class SecretStoreCrypto {
  Future<EncryptedSecretStore> encrypt(
    String plaintext,
    Uint8List masterSecret,
  );
  Future<String> decrypt(EncryptedSecretStore store, Uint8List masterSecret);
}
