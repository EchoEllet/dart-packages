A helper library for storing application secrets in an encrypted file using
the master secret provided by the XDG Desktop Portal Secret API. Designed to
complement [`package:xdg_desktop_portal`](https://pub.dev/packages/xdg_desktop_portal).

To add the dependencies:

```shell
dart pub add xdg_secret_portal_store xdg_secret_portal_store_default xdg_desktop_portal
```

## Usage

```dart
import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';
import 'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';
import 'package:xdg_secret_portal_store_default/xdg_secret_portal_store_default.dart';

final portalClient = XdgDesktopPortalClient();

final store = XdgSecretPortalStore(
  masterSecretRetriever: portalClient.secret.retrieveSecret,
  persistence: SecretStorePersistenceFile(
    // Read the "File Path" section for details.
    File('/path/to/application/data/secrets.json'),
  ),
  // Read the "Cryptography" section for details.
  crypto: SecretStoreCryptoDefault(),
);

await store.loadMasterSecret();

final Map<String, String> secrets = await store.read();

secrets['password'] = '123';
await store.write(secrets);

// Closes the client when no longer needed.
await portalClient.close();
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

This package does not provide a default cryptographic implementation. A `SecretStoreCrypto` implementation must be supplied, either by using [`package:xdg_secret_portal_store_default`](https://pub.dev/packages/xdg_secret_portal_store_default#cryptography) or by providing a custom implementation.

The cryptographic implementation and its security considerations are documented in the README of `package:xdg_secret_portal_store_default`.

> [!NOTE]
> When a custom implementation is used, the consumer
is responsible for compatibility and migrations. `xdg_secret_portal_store` and
its companion package cannot assume the implementation details.

### Custom implementation

In this case, `package:xdg_secret_portal_store_default` is not required.

To use a different crypto library or a different algorithm:

```dart
import 'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';

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

> [!TIP]
> Consumers are strongly encouraged to read the [Secret Portal specification](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Secret.html#org-freedesktop-portal-secret-retrievesecret).

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
- `ciphertext` is the Base64-encoded encrypted UTF-8 JSON representation of the secret map (`Map<String, String>`).
- `mac` is the Base64-encoded message authentication code. Also known as the authentication tag.

## File Path

This package does not define a default file path. Applications should store
the encrypted secret store in their own application data directory.

A typical XDG-compatible layout is:

`$XDG_DATA_HOME/$APPLICATION_ID/xdg_secret_portal_store/secrets.json`.

For example, [`path_provider`](https://pub.dev/packages/path_provider) can be used:

```dart
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

final filePath = p.join(
  await getApplicationSupportPath(),
  'xdg_secret_portal_store',
  'secrets.json',
);

final store = XdgSecretPortalStore(
  persistence: SecretStorePersistenceFile(File(filePath)),
);
```

> [!TIP]
> To keep a package independent of Flutter, use [`xdg_directories`](https://pub.dev/packages/xdg_directories), which is [used by `path_provider_linux`](https://github.com/flutter/packages/blob/af136ccab198bc7dfa25f5fa5ace23fdbcdaadc7/packages/path_provider/path_provider_linux/lib/src/path_provider_linux.dart#L10).
>
> To get the application ID on Linux, the package [`linux_application_id`](https://pub.dev/packages/linux_application_id) can be used.
>
> See also: [`get_application_id_real.dart` of `path_provider_linux`](https://github.com/flutter/packages/blob/af136ccab198bc7dfa25f5fa5ace23fdbcdaadc7/packages/path_provider/path_provider_linux/lib/src/get_application_id_real.dart#L64)

Additionally, `SecretStorePersistence` can be implemented to provide a custom
persistence implementation (which can be independent of `dart:io`'s `File`):

```dart
class SecretStorePersistenceDatabase implements SecretStorePersistence {
  // ...
}

final store = XdgSecretPortalStore(
  persistence: SecretStorePersistenceDatabase(),
);
```

## Not interoperable with GNOME libsecret

This package cannot retrieve secrets stored by
[GNOME libsecret](https://gitlab.gnome.org/GNOME/libsecret).

GNOME libsecret supports multiple storage backends. The two main ones are:

> If available, secrets are stored in the freedesktop secret service. Otherwise, secrets are stored in a file that is encrypted using a master secret that was provided by the secret portal.

If GNOME libsecret is using the Secret Portal backend (see [secret-backend.c#L156](https://github.com/GNOME/libsecret/blob/28486191b2d2cf1599cd3c051b304fac927e24cf/libsecret/secret-backend.c#L156)), it stores encrypted secrets in its own encrypted file format. According to
[this source](https://github.com/GNOME/libsecret/blob/311ca720dd5da208e6ca1364e690026ab0248476/libsecret/secret-file-backend.c#L80),
the data is stored in:

```
$XDG_DATA_HOME/keyrings/<default-collection>.keyring
```

If GNOME libsecret is using the Secret Service backend, this package is also not interoperable. However,
[`package:freedesktop_secret`](https://pub.dev/packages/freedesktop_secret) is interoperable with GNOME libsecret when using that backend.

## See also

- [`package:freedesktop_secret`](https://pub.dev/packages/freedesktop_secret): a client for the [Secret Service API](https://specifications.freedesktop.org/secret-service/latest-single/) (`org.freedesktop.secrets`).

> [!TIP]
> Using direct access to the Secret Service API may result in
> [Flathub app submission not being approved](https://docs.flathub.org/docs/for-app-authors/requirements#permissions).
> New sandboxed applications should consider the XDG Desktop Portal Secret API when
> available.
