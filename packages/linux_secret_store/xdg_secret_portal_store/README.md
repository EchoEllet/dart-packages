A helper library for storing application secrets in an encrypted file using
the master secret provided by the XDG Desktop Portal Secret API. Designed to
complement [`package:xdg_desktop_portal`](https://pub.dev/packages/xdg_desktop_portal).

## Usage

```dart
import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';
import 'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';

final portal = XdgDesktopPortalClient();

try {
  final store = XdgSecretPortalStore(
    secretRetriever: portal.secret.retrieveSecret,
  );

  await store.loadMasterSecret();

  final Map<String, String> secrets = await store.read();
  secrets['password'] = '123';
  await store.write(secrets);
} finally {
  await portal.close();
}
```

> [!TIP]
> This package is intended to be a helper library rather than a portal client.
>
> The portal [`org.freedesktop.portal.Secret`](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Secret.html)
> provides a master secret for a sandboxed application.
>
> `package:xdg_desktop_portal` already implements the secret portal
> ([`XdgSecretPortal`](https://pub.dev/documentation/xdg_desktop_portal/latest/xdg_desktop_portal/XdgSecretPortal-class.html)).
>
> Unlike `org.freedesktop.secrets`, the Secret Portal is not a secure storage API
> itself. This package provides a convenient encrypted secret store built on top
> of the portal-provided master secret.

## Cryptography

The [Secret Portal specification](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Secret.html#org-freedesktop-portal-secret-retrievesecret) states:

> The master secret can be used for encrypting confidential data, but its format
> is opaque to the application. In particular, the length of the secret might
> not be sufficient for use with certain encryption algorithms. In that case,
> the application is supposed to expand it using a KDF algorithm.

The default implementation of this package:

- derives a 32-byte encryption key using **HKDF-SHA-256** with
  `xdg_secret_portal_store` as the HKDF `info` value.
- uses **XChaCha20-Poly1305** for authenticated encryption of the secret store.

The cryptographic operations are implemented using
[`package:cryptography`](https://pub.dev/packages/cryptography).

Additionally, you may implement `SecretStoreCrypto` to provide a custom crypto
implementation (which can be independent of `package:cryptography`):

```dart
class SecretStoreCryptoCustom implements SecretStoreCrypto {
  // ...
}
```

To override it:

```dart
final store = XdgSecretPortalStore(
  crypto: SecretStoreCryptoCustom(),
);
```

## Storage format

Secrets are stored as a UTF-8 encoded JSON file with the following structure:

```json
{
  "version": 1,
  "kdf": "HKDF-SHA256",
  "cipher": "XChaCha20-Poly1305",
  "nonce": "...",
  "ciphertext": "...",
  "mac": "..."
}
```

Where:

- `version` is the serialized storage format version.
- `kdf` identifies the key derivation function used to derive the encryption key.
- `cipher` is the authenticated encryption (AEAD) algorithm.
- `nonce` is the Base64-encoded nonce.
- `ciphertext` is the Base64-encoded encrypted secret store.
- `mac` is the Base64-encoded message authentication code.

## File Path

By default, the encrypted secret store is stored at:

`$XDG_DATA_HOME/xdg_secret_portal_store/secrets.json`.

To override the file path:

```dart
import 'dart:io';

final store = XdgSecretPortalStore(
  persistence: SecretStorePersistenceFile(File(...)),
);
```

Additionally, you may implement `SecretStorePersistence` to provide a custom
persistence implementation (which can be independent of `dart:io`'s `File`):

```dart
class SecretStorePersistenceDatabase implements SecretStorePersistence {
  // ...
}
```

## Disclaimer

Support for this library is given as _best effort_.

This library has not been reviewed or vetted by security professionals.

## See also

- [`package:freedesktop_secret`](https://pub.dev/packages/freedesktop_secret): a client for the [Secret Service API](https://specifications.freedesktop.org/secret-service/latest-single/) (`org.freedesktop.secrets`).

> [!TIP]
> Using direct access to the Secret Service API may result in
> [Flathub app submission not being approved](https://docs.flathub.org/docs/for-app-authors/requirements#permissions).
> New sandboxed applications should consider the XDG Desktop Portal Secret API when
> available.
