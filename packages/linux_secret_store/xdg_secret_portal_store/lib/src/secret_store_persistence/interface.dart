import 'package:xdg_secret_portal_store/src/encrypted_secret_store.dart';

/// Defines persistence operations for the encrypted secret store.
///
/// Implementations can provide different storage backends.
abstract interface class SecretStorePersistence {
  Future<EncryptedSecretStore?> read();
  Future<void> write(EncryptedSecretStore store);
}
