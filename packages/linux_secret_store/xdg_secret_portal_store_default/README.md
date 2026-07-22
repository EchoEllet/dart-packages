
A default crypto implementation of [`package:xdg_secret_portal_store`](https://pub.dev/packages/xdg_secret_portal_store) that uses [`package:cryptography`](https://pub.dev/packages/cryptography).

## Usage

```dart
import 'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';
import 'package:xdg_secret_portal_store_default/xdg_secret_portal_store_default.dart';

final store = XdgSecretPortalStore(
  // ...
  crypto: SecretStoreCryptoDefault(),
);
```

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
However, this is an implementation detail and may change in the future.

## Disclaimer

Support for this library is given as _best effort_.

This library has not been reviewed or vetted by security professionals.
