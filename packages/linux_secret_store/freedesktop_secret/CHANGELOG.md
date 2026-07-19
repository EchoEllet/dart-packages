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
