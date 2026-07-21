import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:xdg_secret_portal_store/src/secret_store_crypto/default.dart';
import 'package:xdg_secret_portal_store/src/secret_store_crypto/interface.dart';
import 'package:xdg_secret_portal_store/src/secret_store_persistence/interface.dart';

export 'src/encrypted_secret_store.dart';
export 'src/secret_store_crypto/interface.dart';
export 'src/secret_store_persistence/file.dart';
export 'src/secret_store_persistence/interface.dart';

typedef MasterSecretRetriever = Future<Uint8List> Function({String? token});

/// A map of secret names to secret values.
typedef SecretMap = Map<String, String>;

/// A helper for storing application secrets in an encrypted file using the
/// master secret provided by the XDG Desktop Portal Secret API.
///
/// Designed to complement [package:xdg_desktop_portal](https://pub.dev/packages/xdg_desktop_portal):
///
/// ```dart
/// import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';
/// import 'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';
///
/// final client = XdgDesktopPortalClient();
///
/// final store = XdgSecretPortalStore(
///   secretRetriever: client.secret.retrieveSecret,
///   persistence: SecretStorePersistenceFile(File(...)),
/// );
///
/// await store.loadMasterSecret();
///
/// await store.write({'password': '123'});
/// ```
///
/// The master secret is retrieved through the provided [secretRetriever] and
/// used to encrypt and decrypt the secret store.
///
/// Call [loadMasterSecret] before using [read] or [write].
class XdgSecretPortalStore {
  XdgSecretPortalStore({
    required MasterSecretRetriever secretRetriever,
    required SecretStorePersistence persistence,
    SecretStoreCrypto? crypto,
  }) : _persistence = persistence,
       _secretRetriever = secretRetriever,
       _crypto = crypto ?? SecretStoreCryptoDefault();

  final MasterSecretRetriever _secretRetriever;
  final SecretStorePersistence _persistence;
  final SecretStoreCrypto _crypto;

  Uint8List? _masterSecret;
  Uint8List get _masterSecretOrThrow =>
      _masterSecret ??
      (throw StateError(
        'Secret store master secret has not been loaded. '
        'Call loadMasterSecret() first.',
      ));

  /// Retrieves and caches the master secret.
  ///
  /// Must be called before using [read] or [write].
  Future<void> loadMasterSecret() async {
    _masterSecret = await _secretRetriever();
  }

  /// Encrypts and stores the provided secrets.
  Future<void> write(SecretMap map) async {
    final masterSecret = _masterSecretOrThrow;

    final encrypted = await _crypto.encrypt(jsonEncode(map), masterSecret);

    await _persistence.write(encrypted);
  }

  /// Reads and decrypts the stored secrets.
  ///
  /// Returns an empty map if no stored secrets exist.
  Future<SecretMap> read() async {
    final masterSecret = _masterSecretOrThrow;

    final encrypted = await _persistence.read();
    if (encrypted == null) {
      return {};
    }

    final plaintext = await _crypto.decrypt(encrypted, masterSecret);

    return (jsonDecode(plaintext) as Map<String, dynamic>)
        .cast<String, String>();
  }

  /// Attempts to clear the cached master secret from memory.
  void clearMasterSecret() {
    try {
      // Attempt to clear possibly sensitive data from the heap.
      // Similar to: https://github.com/dint-dev/cryptography/blob/8c701f6c3dc541ef432aa5ce78c1116f22444ddd/cryptography/lib/src/cryptography/cipher.dart#L270-L271
      _masterSecret?.fillRange(0, _masterSecret!.length, 0);
    } finally {
      _masterSecret = null;
    }
  }
}
