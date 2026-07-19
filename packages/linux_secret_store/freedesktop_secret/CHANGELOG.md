## 0.0.1-dev.6

- Documents that `LookupSecretDuplicateStrategy.first` and `.last`, and `DeleteSecretDuplicateStrategy.first` and `.last`, depend on the ordering returned by the Secret Service implementation and should **not** be relied upon.
- Adds timestamp-based duplicate strategies to `LookupSecretDuplicateStrategy` and `DeleteSecretDuplicateStrategy`:
  - `oldestCreated`
  - `newestCreated`
  - `oldestModified`
  - `newestModified`

  Secret Service timestamps have second resolution. Timestamp-based duplicate strategies **cannot** distinguish between items with identical timestamps. This may affect automated integration tests that create multiple matching secrets within the same second.
- **Note:** Consumers using exhaustive `switch` statements over `LookupSecretDuplicateStrategy` and/or `DeleteSecretDuplicateStrategy` may need to handle the new enum values.
- Fixes false negatives in integration tests caused by service implementation differences on GNOME and Cinnamon.
- Adds a "Verified Secret Service implementations" section to the README.

## 0.0.1-dev.5

- Adds a new recommendation in README.
- Deprecates `SecretServiceCollectionNotFoundException`. `FreeDesktopSecret.storeSecret()` now automatically creates the default collection when `collection` is omitted. For [more details](https://github.com/EchoEllet/dart-packages/issues/2).

## 0.0.1-dev.4

- Updates `freedesktop_secret.dart` to export `src/exceptions.dart`.
- Adds Linux integration tests verifying interoperability with GNOME libsecret.

## 0.0.1-dev.3

- Adds Linux integration tests against Secret Service implementations.
- Updates the `FreeDesktopSecret.storeSecret()` documentation to clarify that `replace: true` does not necessarily update an existing secret's label.
  - The Secret Service specification does not explicitly define this behavior.
  - Tested Secret Service implementations (KWallet) preserve the existing label while updating the secret value.
- Updates the `FreeDesktopSecret.deleteSecret()` documentation.
- Updates README.
- Removes the unnecessary Flutter SDK constraint from `pubspec.yaml`.
  - `freedesktop_secret` is a Dart package and does not depend on Flutter.
- Updates client lifecycle handling.
  - All methods except `initialize()` and `close()` now require an initialized client. Previously, they silently returned `null` or `void`.
  - Calling methods before initialization or after closing the client throws a `StateError`.

## 0.0.1-dev.2

- Fixes minor style issues in the generated D-Bus Dart bindings to satisfy pub pass static analysis.
- Adds a new recommendation in README.

## 0.0.1-dev.1

- Initial version.
