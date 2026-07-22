## 0.2.0

- **BREAKING CHANGE**: Renames `XdgSecretPortalStore.secretRetriever` to `XdgSecretPortalStore.masterSecretRetriever`.

- **BREAKING CHANGE**: Moves the default cryptographic implementation to the new [`xdg_secret_portal_store_default`](http://pub.dev/packages/xdg_secret_portal_store_default) package. `xdg_secret_portal_store` no longer depends on [`package:cryptography`](https://pub.dev/packages/cryptography) and now requires a `SecretStoreCrypto` implementation to be supplied explicitly.

### Migration

Add the companion package:

```shell
dart pub add xdg_secret_portal_store_default
```

Pass it to `crypto` parameter:

```dart
'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';
import 'package:xdg_secret_portal_store_default/xdg_secret_portal_store_default.dart';

final store = XdgSecretPortalStore(
  // ...
  crypto: SecretStoreCryptoDefault(),
);
```

See [this issue](https://github.com/Skyost/SimpleSecureStorage/issues/16) for the breaking change justification and use case.

## 0.1.1

- Shortens the package description to satisfy pub static analysis.

## 0.1.0

- Initial version.
