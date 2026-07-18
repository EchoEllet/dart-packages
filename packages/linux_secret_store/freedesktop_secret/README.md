# Dart Client for Linux Secret Service

A Dart client implementation for the freedesktop.org Secret Service API
([`org.freedesktop.secrets`](https://specifications.freedesktop.org/secret-service/latest-single/))
for storing and retrieving secrets through a Secret Service provider.

## Context

On Linux, XDG is a set of specifications developed by [freedesktop.org](https://freedesktop.org/) to improve interoperability and provide shared technologies across desktop environments.

This Dart package communicates with the freedesktop.org [Secret Service specification](https://specifications.freedesktop.org/secret-service/latest/) over D-Bus, making it compatible with any compliant Secret Service implementation (e.g., GNOME Keyring, KDE Wallet).

## Requirements

These requirements are typically already satisfied by default on most Linux desktop environments.

- A Linux operating system
- A running Secret Service implementation (e.g., GNOME Keyring, KDE Wallet or another implementation of the `org.freedesktop.secrets` D-Bus service)
- D-Bus support

> [!TIP]
> While this package can read and write secrets stored by GNOME Libsecret since both use the same Secret Service backend ([more details](#migration-from-gnome-libsecret)), it does **not** require installing Libsecret packages (e.g., `libsecret-1-0` or `libsecret-1-dev` on Ubuntu).

> [!IMPORTANT]
> This package intentionally does not support [`org.freedesktop.portal.Secret`](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Secret.html). It is a different backend with different semantics, dependencies, error handling, and requires the client to encrypt secrets before storing them.
> 
> Instead, a separate package named `freedesktop_secret_portal` is planned. A higher-level package may later provide a unified API over both backends, hiding their implementation differences.

## Usage

Example:

```dart
import 'package:freedesktop_secret/freedesktop_secret.dart';

final client = FreeDesktopSecret();
await client.initialize();

// Replace '<APPLICATION_ID>' with your Linux application ID.
const lookupAttributes = {
  'xdg:schema': '<APPLICATION_ID>',
  'key': 'refresh_token_example_key',
};

await client.storeSecretText(
  attributes: lookupAttributes,
  secret: '123',
  label: 'User Refresh Token',
  replace: true,
);

print('Stored secret');

final secret = await client.lookupSecret(
  attributes: lookupAttributes,
  duplicateStrategy: LookupSecretDuplicateStrategy.first,
);

print('Looked up secret: ${secret?.secretAsText()}');

await client.deleteSecret(
  attributes: lookupAttributes,
  duplicateStrategy: DeleteSecretDuplicateStrategy.deleteAll,
);

print('Deleted the secret');

final int secretCount = await client.countSecrets(
  attributes: lookupAttributes,
);

print('Matching secrets: $secretCount');
```

> [!TIP]
> Calling `client.close()` is typically not necessary.
> The client can remain open for the application's lifetime and
> will be cleaned up automatically when the application exits.

## Status

This package is **experimental** and not yet considered stable. The API may change before the first stable release (`1.0.0`).

It has [integration tests](./integration_test/), but requires broader validation across different Secret Service implementations and more real-world usage.

All breaking changes will be documented in `CHANGELOG.md`, regardless of the package's stability status.

## [Lookup attributes](https://specifications.freedesktop.org/secret-service/latest-single/#lookup-attributes)

Lookup attributes identify a stored secret and are used to retrieve or delete it later. Services implementing this API will probably store attributes in an **unencrypted** manner in order to support simple and efficient lookups.

Changing lookup attributes after storing a secret is a breaking change, as the same secret can no longer be retrieved using the new attributes.

### `xdg:schema` attribute (optional)

The `xdg:schema` attribute is optional and is not part of the Secret Service specification (GNOME Libsecret sets it internally). However, we recommend setting it to your application ID (or another unique, stable identifier) to avoid collisions with other applications and for compatibility with GNOME Libsecret ([more details](#migration-from-gnome-libsecret)).

```dart
const lookupAttributes = {
  'xdg:schema': '<APPLICATION_ID>',
  // Other attributes here...
};

// Important: Use the same lookup attributes for all operations to access the same secret item.
await client.storeSecretText(attributes: lookupAttributes);
await client.lookupSecret(attributes: lookupAttributes);
await client.deleteSecret(attributes: lookupAttributes);
```

### Lookup duplication strategy

Lookup attributes are not unique constraints. A lookup may return multiple matching items if multiple secrets have the same attributes.

To control how duplicate matches are handled:

```dart
await client.lookupSecret(
  attributes: ...,
  duplicateStrategy: LookupSecretDuplicateStrategy.first,
);

await client.deleteSecret(
  attributes: ...,
  duplicateStrategy: DeleteSecretDuplicateStrategy.deleteAll,
);
```

The default is `.throwException` to avoid silently returning or deleting an unexpected secret.

> [!TIP]
> According to [this source](https://git.cypherstack.com/Cypher_Stack/libsecret/src/commit/a773060332728385c09a0f1f436dabecfef802ae/docs/reference/libsecret/libsecret-c-examples.md#lookup-a-password), GNOME Libsecret handles duplicate matches by returning the most recently stored item.

> [!TIP]
> When storing secrets, use `replace: true` to update an existing item with the same lookup attributes instead of creating duplicate items. However, duplicates may still occur, so lookup duplication handling is still required.

## Prompting

The Secret Service may require user interaction to complete an operation, such as unlocking an item or collection. The specification explicitly recommends that clients do not assume objects are already unlocked ([source](https://specifications.freedesktop.org/secret-service/latest-single/#unlocking)):

> A client application should always be ready to unlock the items for the secrets it needs, or objects it must modify. It must not assume that an item is already unlocked for whatever reason.

This library automatically handles lock checks, unlocking, prompting, waiting for the prompt's Completed signal, checking whether the prompt was dismissed, and processing the operation-specific result.

If a prompt is required, the method awaits until the prompt completes. This happens when the user either dismisses the prompt or completes the required action (for example, entering their password). During this time, you may wish to display a loading or progress indicator in your application's UI.

### Providing [Window ID](https://specifications.freedesktop.org/secret-service/latest-single/#id-1.3.3.6.4.2.4.1) (optional)

By default, this library passes an empty window ID (`""`) to the Secret Service. If your application can provide a platform-specific window handle, you may supply it to allow the desktop environment to associate prompts with your application's window (for example, presenting them as a transient dialog).

```dart
final client = FreeDesktopSecret(
  windowIdProvider: () async => ...,
);
```

## D-Bus session

By default, this library lazily creates a new D-Bus client session ([`DBusClient.session()`](https://pub.dev/documentation/dbus/latest/dbus/DBusClient/DBusClient.session.html)) for each `FreeDesktopSecret` instance.

This behavior can be overridden:

```dart

final dbusClient = DBusClient.session();
final client = FreeDesktopSecret(
  dbusClientProvider: () => dbusClient,
);
```

> [!NOTE]
> However, when a non-null `dbusClientProvider` is provided, `FreeDesktopSecret.close()` does not call [`DBusClient.close()`](https://pub.dev/documentation/dbus/latest/dbus/DBusClient/close.html). In that case, the caller retains ownership of the `DBusClient` instance and is responsible for closing it.
>
> This ownership model is consistent with other Linux D-Bus packages, such as [avahi](https://github.com/canonical/avahi.dart/blob/3ebbfc338d064f2f95843668968d27610c521ed8/lib/src/avahi_client.dart#L11-L23) and [xdg_desktop_portal](https://github.com/canonical/xdg_desktop_portal.dart/blob/e5b0701ca6e2d263def37fdbd2635e5beadf649a/lib/src/xdg_desktop_portal_client.dart#L105-L107).

## Migration From [GNOME Libsecret](https://gnome.pages.gitlab.gnome.org/libsecret/)

Since both Libsecret and this package communicate with the same Secret Service API over D-Bus, compatibility can be retained (i.e., without removing existing user data).

For example, the following schema definition in GNOME Libsecret:

```c
#include <libsecret/secret.h>

static const SecretSchema my_schema = {
    "org.example.Example",
    SECRET_SCHEMA_NONE,
    {
        { "service", SECRET_SCHEMA_ATTRIBUTE_STRING },
        { "account", SECRET_SCHEMA_ATTRIBUTE_STRING },
        { NULL, 0 },
    }
};

gchar *password = secret_password_lookup_sync(
    &my_schema,
    NULL,
    NULL,
    "service", ...,
    "account", ...,
    NULL
);

/* Full example: https://gnome.pages.gitlab.gnome.org/libsecret/libsecret-c-examples.html#lookup-a-password */
```

Uses the schema name `org.example.Example` and defines two string attributes: `service` and `account`.

The equivalent lookup in Dart:

```dart
import 'package:freedesktop_secret/freedesktop_secret.dart';

final FreeDesktopSecret client = ...;

final secret = await client.lookupSecret(
  attributes: {
    'xdg:schema': 'org.example.Example',
    'service': ...,
    'account': ...,
  },
);
```

The `xdg:schema` attribute corresponds to the Libsecret schema name (Libsecret [sets it internally](https://github.com/GNOME/libsecret/blob/3ebda96b5f309407f426c1b4071d334ac6648f8c/libsecret%2Fsecret-attributes.c#L37)). The other keys correspond to the schema attributes, and their values should match the attributes used when storing the item.

## Compatibility with existing packages

Some packages may use a hardcoded schema name when using GNOME Libsecret on Linux.

> [!TIP]
> The lookup attributes shown above bellow internal implementation details of the respective plugins and may change over time. However, changing them is a breaking change.

### [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage)

> [!NOTE]
> There is [a pull request](https://github.com/juliansteenbakker/flutter_secure_storage/pull/1182) that updates `flutter_secure_storage_linux` to use `freedesktop_secret` for early testing.

[`flutter_secure_storage_linux`](https://github.com/juliansteenbakker/flutter_secure_storage/tree/develop/flutter_secure_storage_linux/linux/include) stores all key-value pairs in a single item as JSON.

For example:

```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'username', value: 'flutter_user');
```

In the current [`flutter_secure_storage_linux`](https://github.com/juliansteenbakker/flutter_secure_storage/tree/develop/flutter_secure_storage_linux) implementation, the item can be looked up using:

```dart
// Replace <APPLICATION_ID> with your Flutter Linux application ID,
// for example: 'org.example.Example'

final applicationId = '<APPLICATION_ID>';

final lookupAttributes = {
  'account': '$applicationId.secureStorage',
  // Normally, 'xdg:schema' should be explicitly defined with a
  // unique value. However, the current flutter_secure_storage_linux
  // implementation stores an incorrect value due to a historical bug.
  // It is omitted here to match existing data regardless of the stored
  // value. This is not expected to be an issue since 'account' is
  // already unique. Changing this would require data migration or a
  // breaking change:
  // https://github.com/juliansteenbakker/flutter_secure_storage/issues/1181
  // 'xdg:schema': ...,
};

final secret = await client.lookupSecret(attributes: lookupAttributes);

if (secret == null) {
    print('Secret not found');
    return;
}

final secrets = jsonDecode(secret.secretAsText());
print('Found secret: ${secrets['username']}');

print('Deleting all flutter_secure_storage secrets of "$applicationId"');

await client.deleteSecret(attributes: lookupAttributes);
```

The application ID can be found in `linux/CMakeLists.txt`:

```cmake
set(APPLICATION_ID "...")
```

### [`simple_secure_storage`](https://pub.dev/packages/simple_secure_storage)

[`simple_secure_storage_linux` uses the schema `fr.skyost.SimpleSecureStorage` with `data` attribute](https://github.com/Skyost/SimpleSecureStorage/blob/5940541cbb2a457a43735a6047434354c49bf77e/packages/simple_secure_storage_linux/linux/simple_secure_storage_linux_plugin.cc#L25-L36):

```c
const SecretSchema* get_schema (void){
    static const SecretSchema schema = {
      "fr.skyost.SimpleSecureStorage",
      SECRET_SCHEMA_NONE,
      {
        {"data", SECRET_SCHEMA_ATTRIBUTE_STRING},
        {"NULL", SECRET_SCHEMA_ATTRIBUTE_STRING},
      }
    };
    return &schema;
}
```

The equivalent lookup attributes in Dart:

```dart
final lookupAttributes = {
  'xdg:schema': 'fr.skyost.SimpleSecureStorage',
  'data': ...,
};
```

### [`biometric_storage`](https://pub.dev/packages/biometric_storage)

[`biometric_storage` uses the schema `design.codeux.BiometricStorage` with `name` attribute](https://github.com/authpass/biometric_storage/blob/main/linux/biometric_storage_plugin.cc#L62-L73):

```c
const SecretSchema *
biometric_get_schema (void)
{
    static const SecretSchema the_schema = {
        "design.codeux.BiometricStorage", SECRET_SCHEMA_NONE,
        {
            {  "name", SECRET_SCHEMA_ATTRIBUTE_STRING },
            // {  "NULL", 0 },
        }
    };
    return &the_schema;
}
```

The equivalent lookup attributes in Dart:

```dart
final lookupAttributes = {
  'xdg:schema': 'design.codeux.BiometricStorage',
  'name': ...,
};
```

### [dbus_secrets](https://pub.dev/packages/dbus_secrets)

`dbus_secrets` uses a simple [key-value lookup](https://github.com/akshaybabloo/dbus_secrets/blob/31da1752a3dd23bc82691f7a56d3239f6d63eadc/lib/dbus_secrets.dart#L227) and does not use GNOME Libsecret.

The lookup attributes:

```dart
final applicationId = '<APPLICATION_ID>';
final lookupAttributes = {
  'Application': applicationId,
  'Id': '<KEY>',
};
```

## Recommendations

### Do not assume previously stored secrets exist

Applications should **not** assume that a previously stored secret will always exist, even if the application itself is responsible for creating and deleting it.

Instead, they should always be prepared to handle a missing secret. For example, if a refresh token is unavailable, the application should reauthenticate the user, invalidate the session, or log the user out.

Secrets may be removed by the user, another application, the Secret Service implementation, or become inaccessible if the user switches Secret Service implementations (e.g., KDE Wallet to KeePassXC).

### Include at least one application-unique attribute

For example:

```dart
{
  'xdg:schema': '<APPLICATION_ID>',
}
```

More details in [this section](#xdgschema-attribute-optional).

There are exceptional cases, such as migration from another implementation. In those cases, use the lookup attributes expected by that implementation.

### For library authors: Allow overriding `FreeDesktopSecret`

Prefer explicitly requiring a `FreeDesktopSecret` instance:

```dart
void example({required FreeDesktopSecret freeDesktopSecretClient}) {
  // ...
}
```

Or allow one to be provided while creating a default instance when omitted:

```dart
void example({FreeDesktopSecret? freeDesktopSecretClient}) {
  final client = freeDesktopSecretClient ?? FreeDesktopSecret();
}
```

### For library authors: do not hardcode the application ID

Hardcoding an application ID or `xdg:schema` causes all applications using the same library to share the same namespace. This can lead to collisions, unintended access to another application's secrets, or force applications to choose a duplication strategy (see [Lookup duplication strategy](#lookup-duplication-strategy)).

In fact, GNOME libsecret always uses a schema in normal usage.

Consider this schema:

```dart
{
  'xdg:schema': linuxApplicationId(), // e.g., via FFI or method channel
  'package': 'flutter_secure_storage', // Example package name
}
```

This approach allows a library to identify its own secrets within each application, while keeping different applications isolated from one another. It also makes it straightforward for application developers to migrate or access the library's secrets when needed, without risking collisions between unrelated applications or packages.

Later, package authors can use this lookup to retrieve only the secrets created by their package:

```dart
{
  'xdg:schema': linuxApplicationId(),
  'package': 'flutter_secure_storage',
}
```

Application developers can use this lookup to retrieve all secrets belonging to their application, regardless of the package:

```dart
{
  'xdg:schema': linuxApplicationId(),
}
```

> [!TIP]
> The package [`linux_application_id`](https://pub.dev/packages/linux_application_id) provides synchronous access to the Linux application ID using Dart FFI.

### Handle thrown `Exception`s

When performing operations such as storing or retrieving secrets, prefer catching `Exception`.

Although many failures seem uncommon in practice, catching `Exception` ensures that both D-Bus exceptions (such as `DBusErrorException` and `DBusMethodResponseException`) and library-specific exceptions derived from `SecretServiceException` are handled.

```dart
try {
  // Your operations here...
} on Exception catch (e) {
  ...
}
```

If you are writing a library, consider avoiding patterns like this:

```dart
// Avoid this pattern when possible.

try {
  // Your operations here...
  print('Succeeds');
  return true;
} catch (e) {
  print('An error occurs: $e');
  return false;
}
```

This pattern has several limitations:

- Catches programming errors that should typically be fixed rather than handled at runtime (for example, `ArgumentError`, `StateError`). There is a [Dart lint](https://dart.dev/tools/linter-rules/avoid_catching_errors) to avoid this.
- Hardcodes a logging strategy, making it inconsistent with the application's chosen logging framework or telemetry.
- Prevents applications from handling exceptions explicitly. For example, an application may want to display a specific message when a `SecretServicePromptDismissedException` is thrown, or recover when no Secret Service implementation or D-Bus session is available.
- Silently converts failures into a return value that hides the original exception, stack trace, and other diagnostic information. This may prevent them from being reported by crash reporting tools such as Sentry if the exception is not handled.
  - Applications can still map exceptions to `Result` failures according to their own error-handling requirements.

> [!TIP]
> This recommendation is **not specific** to `freedesktop_secret`. The same guidance generally applies when using libraries such as `dart:io`, `package:flutter_secure_storage`, and many other Dart and Flutter packages.

## Limitations

### Supports only plain algorithm for transferring secrets

When transferring secrets between the client and the Secret Service implementation, this client currently only supports [Algorithm: plain](https://specifications.freedesktop.org/secret-service/latest-single/#id-1.2.8.7).

This does **not** mean that secrets are stored on disk without encryption. It only refers to the algorithm used for transferring secret values between the client and the service.

The specification strongly recommends that service implementations (e.g., GNOME Keyring, KDE Wallet) support the plain algorithm:

> It is strongly recommended that a service implementing this API support the plain algorithm.

The `dh-ietf1024-sha256-aes128-cbc-pkcs7` algorithm provides an additional layer for transferring secrets, but is not intended as a required security measure. According to the specification:

> The Secrets API has provision to encrypt secrets while in transit between the service and the client application. The encryption is not envisioned to withstand man in the middle attacks, or other active attacks. It is envisioned to minimize storage of plain text secrets in memory and prevent plain text storage of secrets in a swap file or other caching mechanism.
>
> Many client applications may choose not to make use of the provisions to encrypt secrets in transit. In fact for applications unable to prevent their own memory from being paged to disk (eg: Java, C# or Python apps), transferring encrypted secrets would be an exercise of questionable value.

Dart applications generally fall into the same category due to managed memory and garbage collection, making transfer-only encryption **less beneficial** than in environments with more direct memory control (e.g., C, Rust).

This limitation may be addressed in the future, but it is not currently planned.

GNOME Libsecret seems to support both plain and `dh-ietf1024-sha256-aes128-cbc-pkcs7` ([source code](https://github.com/GNOME/libsecret/blob/ac1367056d59a86a5f8e8a446f8a6302fed4cf6b/libsecret/secret-session.c#L42-L43)).

### Default collection usage

According to the specification:

> A group of items together form a collection. A collection is similar in concept to the terms 'keyring' or 'wallet'.

The [specification suggests](https://specifications.freedesktop.org/secret-service/latest-single/#id-1.2.4) that clients **should** use the **default collection** unless there are special requirements:

> Client applications without special requirements should store in the default collection. The default collection is always accessible through a specific object path.

The library uses the default collection by default. While individual operations can still override the collection object path (from raw `dbus`), the library currently does not expose or maintain convenient APIs for creating or managing collections.

For most Flutter applications, this limitation is **not relevant**.

Most Flutter plugins and packages store secrets in the default collection as well (`SECRET_COLLECTION_DEFAULT` in GNOME Libsecret):

- [`flutter_secure_storage_linux`](https://github.com/juliansteenbakker/flutter_secure_storage/blob/621195b91dd82d05fba6e297a8700c68a72ab031/flutter_secure_storage_linux/linux/include/Secret.hpp#L114-L115)
- [`simple_secure_storage_linux`](https://github.com/Skyost/SimpleSecureStorage/blob/5940541cbb2a457a43735a6047434354c49bf77e/packages/simple_secure_storage_linux/linux/simple_secure_storage_linux_plugin.cc#L272)
- [`biometric_storage`](https://github.com/authpass/biometric_storage/blob/0bbd368356518d3c158f6a32e049b5dd8c39060a/linux/biometric_storage_plugin.cc#L160)
- [`dbus_secrets`](https://github.com/akshaybabloo/dbus_secrets/blob/31da1752a3dd23bc82691f7a56d3239f6d63eadc/lib/dbus_secrets.dart#L9)

### Partial FreeDesktop Secret Service API coverage

This package does not expose the entire FreeDesktop Secret Service API (that is, it is not a one-to-one mapping of the D-Bus interface). Instead, it focuses on the functionality commonly required by Flutter applications.

For example, it does not provide an option for the application to programmatically dismiss a service prompt dialog after it has been shown as part of an operation. The user must explicitly confirm or dismiss the prompt themselves.

For most Flutter applications, this limitation is not relevant.

## Related packages

- `freedesktop_secret_portal` (planned) for sandboxed applications (e.g., Flatpak) without direct D-Bus access to `org.freedesktop.secrets`.

## Known `secret-tool lookup` CLI issue (GNOME Libsecret)

`FreeDesktopSecret.storeSecretText()` stores text secrets with the content type `text/plain; charset=utf-8`:

```dart
await client.storeSecretText(secret: '...');
```

This content type is permitted by the Secret Service specification, which even uses `text/plain; charset=utf8` as [an example](https://specifications.freedesktop.org/secret-service/latest-single/#id-1.3.4.2.2.5.4).

`secret-tool search` (from GNOME Libsecret) displays these secrets correctly. However, `secret-tool lookup` rejects the secret with the message `secret does not contain a textual password` because it expects the content type to be exactly `text/plain`.

This is a [known GNOME Libsecret issue](https://gitlab.gnome.org/GNOME/libsecret/-/work_items/114). At the time of writing, there is an [open merge request](https://gitlab.gnome.org/GNOME/libsecret/-/merge_requests/175) to address it.

## Acknowledgements

- [`package:dbus`](https://pub.dev/packages/dbus) (Dart package)
- [`org.freedesktop.Secrets.xml`](https://github.com/GNOME/libsecret/blob/main/libsecret/org.freedesktop.Secrets.xml) D-Bus introspection data was copied from the GNOME Libsecret project source code ([accompanying COPYING file](third_party/libsecret/COPYING)).
