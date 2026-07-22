/// Serialized representation of an encrypted secret store.
class EncryptedSecretStore {
  const EncryptedSecretStore({
    required this.version,
    required this.kdf,
    required this.cipher,
    required this.nonce,
    required this.ciphertext,
    required this.mac,
  });

  factory EncryptedSecretStore.fromJson(Map<String, Object?> json) {
    return EncryptedSecretStore(
      version: json['version']! as int,
      kdf: json['kdf']! as String,
      cipher: json['cipher']! as String,
      nonce: json['nonce']! as String,
      ciphertext: json['ciphertext']! as String,
      mac: json['mac']! as String,
    );
  }

  /// Serialized storage format version.
  final int version;

  /// Key derivation function.
  final String kdf;

  /// Authenticated encryption (AEAD) algorithm.
  final String cipher;

  /// Base64-encoded nonce.
  final String nonce;

  /// Base64-encoded ciphertext.
  final String ciphertext;

  /// Base64-encoded message authentication code.
  /// Also known as the authentication tag.
  final String mac;

  Map<String, Object> toJson() => {
    'version': version,
    'kdf': kdf,
    'cipher': cipher,
    'nonce': nonce,
    'ciphertext': ciphertext,
    'mac': mac,
  };
}
