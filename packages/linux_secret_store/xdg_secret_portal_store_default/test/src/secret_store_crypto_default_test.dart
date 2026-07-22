import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:xdg_secret_portal_store/src/secret_store_crypto/default.dart';
import 'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';

void main() {
  late SecretStoreCrypto crypto;

  setUp(() {
    crypto = SecretStoreCryptoDefault();
  });

  final masterSecret = Uint8List.fromList(List.generate(32, (i) => i));

  test('encrypt and decrypt returns the original plaintext', () async {
    const plaintext = 'hello';

    final encrypted = await crypto.encrypt(plaintext, masterSecret);
    final decrypted = await crypto.decrypt(encrypted, masterSecret);

    expect(decrypted, plaintext);
  });

  test(
    'encrypting the same plaintext twice produces different nonces',
    () async {
      final enc1 = await crypto.encrypt('hello', masterSecret);
      final enc2 = await crypto.encrypt('hello', masterSecret);

      expect(enc1.nonce, isNot(equals(enc2.nonce)));
    },
  );

  test('decrypt throws when the ciphertext is modified', () async {
    final encrypted = await crypto.encrypt('hello', masterSecret);

    final ciphertext = base64Decode(encrypted.ciphertext);
    ciphertext[0] ^= 0x01;

    final corruptedStore = encrypted.copyWith(
      ciphertext: base64Encode(ciphertext),
    );

    await expectLater(
      crypto.decrypt(corruptedStore, masterSecret),
      throwsA(isA<Exception>()),
    );
  });

  test('decrypt throws when the authentication tag is modified', () async {
    final encrypted = await crypto.encrypt('hello', masterSecret);

    final mac = base64Decode(encrypted.mac);
    mac[0] ^= 0x01;

    final corruptedStore = encrypted.copyWith(mac: base64Encode(mac));

    await expectLater(
      crypto.decrypt(corruptedStore, masterSecret),
      throwsA(isA<Exception>()),
    );
  });

  test('decrypt throws when the nonce is modified', () async {
    final encrypted = await crypto.encrypt('hello', masterSecret);

    final nonce = base64Decode(encrypted.nonce);
    nonce[0] ^= 0x01;

    final corruptedStore = encrypted.copyWith(nonce: base64Encode(nonce));

    await expectLater(
      crypto.decrypt(corruptedStore, masterSecret),
      throwsA(isA<Exception>()),
    );
  });

  test('decrypt throws when using a different master secret', () async {
    final encrypted = await crypto.encrypt('hello', masterSecret);

    final differentMasterSecret = Uint8List.fromList(
      List.generate(32, (i) => 255 - i),
    );

    await expectLater(
      crypto.decrypt(encrypted, differentMasterSecret),
      throwsA(isA<Exception>()),
    );
  });

  test('encrypt returns the expected metadata', () async {
    final encrypted = await crypto.encrypt('hello', masterSecret);

    expect(encrypted.version, 1);
    expect(encrypted.kdf, 'HKDF-SHA256');
    expect(encrypted.cipher, 'XChaCha20-Poly1305');
  });

  test('encrypt handles empty plaintext', () async {
    final encrypted = await crypto.encrypt('', masterSecret);
    final decrypted = await crypto.decrypt(encrypted, masterSecret);

    expect(decrypted, isEmpty);
  });

  test('encrypt and decrypt handles unicode plaintext', () async {
    const plaintext = 'こんにちは 🔐';

    final encrypted = await crypto.encrypt(plaintext, masterSecret);
    final decrypted = await crypto.decrypt(encrypted, masterSecret);

    expect(decrypted, plaintext);
  });

  test('encrypt and decrypt handles long plaintext', () async {
    final plaintext = 'a' * 10000;

    final encrypted = await crypto.encrypt(plaintext, masterSecret);
    final decrypted = await crypto.decrypt(encrypted, masterSecret);

    expect(decrypted, plaintext);
  });
}

extension on EncryptedSecretStore {
  EncryptedSecretStore copyWith({
    int? version,
    String? kdf,
    String? cipher,
    String? nonce,
    String? ciphertext,
    String? mac,
  }) {
    return EncryptedSecretStore(
      version: version ?? this.version,
      kdf: kdf ?? this.kdf,
      cipher: cipher ?? this.cipher,
      nonce: nonce ?? this.nonce,
      ciphertext: ciphertext ?? this.ciphertext,
      mac: mac ?? this.mac,
    );
  }
}
