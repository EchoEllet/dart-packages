import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dbus/dbus.dart';
import 'package:freedesktop_secret/freedesktop_secret.dart';
import 'package:freedesktop_secret/src/constants.dart';
import 'package:freedesktop_secret/src/dbus_bindings.g.dart';
import 'package:freedesktop_secret/src/exceptions.dart';
import 'package:freedesktop_secret/src/models/create_item_result.dart';
import 'package:freedesktop_secret/src/models/open_session_result.dart';
import 'package:freedesktop_secret/src/models/secret_value.dart';
import 'package:freedesktop_secret/src/models/unlock_result.dart';

export 'src/duplicate_strategy/delete_secret_duplicate_strategy.dart';
export 'src/duplicate_strategy/lookup_secret_duplicate_strategy.dart';
export 'src/models/secret_item.dart';

typedef DBusClientProvider = FutureOr<DBusClient> Function();
typedef WindowIdProvider = FutureOr<String> Function();

/// A Dart client for the FreeDesktop Secret Service API (`org.freedesktop.secrets`)
/// for storing and retrieving secrets on Linux.
///
/// A [FreeDesktopSecret] instance is intended to be reused for the lifetime
/// of the application. Call [initialize] once before use and [close]
/// when the application shuts down or when it is no longer needed.
///
/// See the official specification:
/// https://specifications.freedesktop.org/secret-service/latest-single/
class FreeDesktopSecret {
  FreeDesktopSecret({
    DBusClientProvider? dbusClientProvider,

    WindowIdProvider? windowIdProvider,
  }) : _dbusClientProvider = dbusClientProvider ?? DBusClient.session,
       _ownsClient = dbusClientProvider == null,
       _windowIdProvider = windowIdProvider ?? (() => '');

  final DBusClientProvider _dbusClientProvider;
  final bool _ownsClient;

  /// Returns the platform-specific window handle to use for showing the prompt.
  final WindowIdProvider _windowIdProvider;

  DBusClient? _cachedClient;
  Future<DBusClient> get _client async =>
      _cachedClient ??= await _dbusClientProvider();

  // Generated D-Bus proxy (internal implementation detail).
  OrgFreedesktopSecrets _remoteObject(
    DBusClient client, {
    DBusObjectPath? path,
  }) {
    return path == null
        ? OrgFreedesktopSecrets(client, Constants.serviceName)
        : OrgFreedesktopSecrets(client, Constants.serviceName, path: path);
  }

  // https://specifications.freedesktop.org/secret-service/latest-single/#sessions
  DBusObjectPath? _sessionObjectPath;
  DBusObjectPath get _sessionObjectPathOrThrow =>
      _sessionObjectPath ??
      (throw throw StateError(
        'Secret Service is not initialized. '
        'Call initialize() before using this operation.',
      ));

  /// Caching this is fine according to [the specification](https://specifications.freedesktop.org/secret-service/latest-single/#id-1.2.4):
  ///
  /// > Under normal circumstances, the object path of a collection or item should not change for its lifetime.
  DBusObjectPath? _defaultCollectionObjectPath;

  /// Initializes the Secret Service session.
  ///
  /// This method can be called again after [close] to reinitialize the instance.
  ///
  /// Throws [SecretServiceSessionNegotiationException] when session negotiation
  /// is incomplete.
  Future<void> initialize() async {
    if (_sessionObjectPath != null) {
      return;
    }
    final serviceObject = _remoteObject(await _client);

    // "plain" refers only to the D-Bus session transfer algorithm. It does not
    // mean secrets are stored in plaintext. The Secret Service API recommends
    // Secret Service implementations (e.g. GNOME Keyring, KDE Wallet) support
    // this algorithm.
    // https://specifications.freedesktop.org/secret-service/latest-single/#id-1.2.8.6
    const algorithm = 'plain';

    final session = await _openSession(
      serviceObject,
      algorithm: algorithm,

      // Should be an empty String if algorithm is "plain"
      // https://specifications.freedesktop.org/secret-service/latest-single/#id-1.2.8.7
      input: const DBusString(''),
    );

    // OpenSession() may return "/" when session negotiation is incomplete.
    // https://specifications.freedesktop.org/secret-service/latest-single/#id-1.2.8.6
    if (session.objectPath == DBusObjectPath.root) {
      throw const SecretServiceSessionNegotiationException(
        algorithm: algorithm,
      );
    } else {
      _sessionObjectPath = session.objectPath;
    }

    final collectionObjectPath = await serviceObject.callReadAlias(
      Constants.defaultAlias,
    );

    // The default collection alias may not exist.
    // This is a valid Secret Service state, not a locked keyring.
    // Context: https://github.com/juliansteenbakker/flutter_secure_storage/pull/1177
    if (collectionObjectPath != DBusObjectPath.root) {
      _defaultCollectionObjectPath = collectionObjectPath;
    }
  }

  Future<OpenSecretSession> _openSession(
    OrgFreedesktopSecrets serviceObject, {
    required String algorithm,
    required DBusValue input,
  }) async {
    final result = await serviceObject.callOpenSession(algorithm, input);

    return OpenSecretSession(
      output: result[0],
      objectPath: result[1].asObjectPath(),
    );
  }

  /// Searches for items matching [attributes] in [collection].
  ///
  /// If [collection] is omitted, the default collection is searched.
  ///
  /// Returns an empty list if [collection] is `null` and the default collection
  /// does not exist.
  Future<List<DBusObjectPath>> _searchItemsInCollection({
    required Map<String, String> attributes,
    required OrgFreedesktopSecrets collectionObject,
  }) async {
    final result = await collectionObject.callSearchItems_(attributes);
    return .unmodifiable(result);
  }

  /// Stores a secret.
  ///
  /// The [attributes] are used for lookup and are **not** part of the secret.
  /// Do not store passwords, tokens, encryption keys, or other sensitive data
  /// in [attributes] (see [Lookup attributes](https://specifications.freedesktop.org/secret-service/latest-single/#lookup-attributes)).
  ///
  /// Sensitive data must be stored in [secretBytes].
  ///
  /// [replace] whether to replace an item with the same attributes or not.
  ///
  /// Exceptions:
  ///
  /// - Throws [SecretServiceCollectionNotFoundException] if [collection] is
  /// omitted and the default collection does not exist.
  ///
  /// - Propagates [DBusUnknownObjectException] if [collection] refers to an unknown
  /// D-Bus object path.
  ///
  /// - Throws [SecretServicePromptDismissedException] if a prompt was required to
  /// complete the operation and the prompt was dismissed.
  ///
  /// - Throws [SecretServiceUnlockException] if the requested collection could not
  /// be unlocked.
  ///
  /// - Throws [SecretServiceCreateItemResultException] if a prompt was required,
  ///   the prompt completed with `dismissed` set to `false`, but the operation-specific
  ///   result did not contain the object path of the newly created item (`/` was returned).
  ///   Rare in practice, but possible in theory.
  Future<void> storeSecret({
    required Map<String, String> attributes,
    required Uint8List secretBytes,
    required String contentType,
    required String label,
    required bool replace,
    DBusObjectPath? collection,
  }) async {
    final collectionPath = collection ?? _defaultCollectionObjectPath;
    if (collectionPath == null) {
      throw const SecretServiceCollectionNotFoundException(
        alias: Constants.defaultAlias,
      );
    }

    final client = await _client;

    final collectionObject = _remoteObject(client, path: collectionPath);

    await _ensureCollectionUnlocked(
      client: client,
      objectPath: collectionPath,
      remoteObject: collectionObject,
    );

    final properties = _createItemProperties(
      label: label,
      attributes: attributes,
    );

    final secret = SecretValue(
      session: _sessionObjectPathOrThrow,
      parameters:
          const [], // No parameters are required for the plain algorithm.
      secretBytes: secretBytes,
      contentType: contentType,
    );

    final rawResult = await collectionObject.callCreateItem(
      properties,
      secret.toDBus(),
      replace,
    );
    final result = _parseCreateItemResult(rawResult);

    // This should never happen in practice, but in theory it may happen if the
    // Secret Service implementation violates the specification:
    // https://specifications.freedesktop.org/secret-service/latest-single/#id-1.3.3.3.4.4.4.4
    assert(
      (result.item == DBusObjectPath.root) !=
          (result.prompt == DBusObjectPath.root),
      'Invalid CreateItem result: exactly one of item and prompt must be "/". '
      'This Secret Service implementation may violate the Secret Service specification.',
    );

    if (result.promptRequired) {
      final promptResult = await _executePrompt(
        client,
        promptPath: result.prompt,
      );

      // According to the specification: "In this case, the result of the prompt will contain the object path of the new item." (for "When creating an item")
      final item = promptResult.asObjectPath();

      if (item == DBusObjectPath.root) {
        throw const SecretServiceCreateItemResultException();
      }
    }
  }

  Future<void> _ensureCollectionUnlocked({
    required DBusClient client,
    required DBusObjectPath objectPath,
    required OrgFreedesktopSecrets remoteObject,
  }) async {
    final isLocked = await remoteObject.getLocked();

    if (isLocked) {
      await _unlockOrThrow(client: client, objectPath: objectPath);
    }
  }

  Future<void> _ensureItemUnlocked({
    required DBusClient client,
    required DBusObjectPath objectPath,
    required OrgFreedesktopSecrets remoteObject,
  }) async {
    final isLocked = await remoteObject.getLocked_();

    if (isLocked) {
      await _unlockOrThrow(client: client, objectPath: objectPath);
    }
  }

  Future<void> _unlockOrThrow({
    required DBusClient client,
    required DBusObjectPath objectPath,
  }) async {
    final unlockResult = await _unlock(client, objects: [objectPath]);

    if (!unlockResult.promptRequired) {
      return;
    }

    final promptResult = await _executePrompt(
      client,
      promptPath: unlockResult.prompt,
    );

    // According to the specification: "The result of the prompt will contain the object paths that were successfully unlocked by the prompt." (for "The Unlock() method may also return a prompt object")
    final unlocked = promptResult.asObjectPathArray().contains(objectPath);

    if (!unlocked) {
      throw const SecretServiceUnlockException();
    }
  }

  CreateItemResult _parseCreateItemResult(List<DBusValue> raw) =>
      CreateItemResult(
        item: raw[0].asObjectPath(),
        prompt: raw[1].asObjectPath(),
      );

  /// Shows a Secret Service prompt and returns the operation-specific result.
  ///
  /// Throws [SecretServicePromptDismissedException] if the prompt was dismissed.
  ///
  /// Note: This method already handles the case where `dismissed` is `true`.
  /// However, even if `dismissed` is `false`, the specification does not
  /// guarantee that the operation was successful. For
  /// [example](https://specifications.freedesktop.org/secret-service/latest-single/#unlocking):
  ///
  /// > The Unlock() method may also return a prompt object. If a prompt object is returned, it must be acted upon in order to complete the unlocking of the remaining objects. The result of the prompt will contain the object paths that were successfully unlocked by the prompt.
  ///
  /// Therefore, callers should **validate** the returned value according to the
  /// operation being performed.
  ///
  /// See also: https://specifications.freedesktop.org/secret-service/latest-single/#id-1.3.3.6.5.2.4.2
  Future<DBusValue> _executePrompt(
    DBusClient client, {
    required DBusObjectPath promptPath,
  }) async {
    final promptObject = _remoteObject(client, path: promptPath);

    final completedFuture = promptObject.completed.first;

    await promptObject.callPrompt(await _windowIdProvider());

    final promptResult = await completedFuture;

    if (promptResult.dismissed) {
      throw const SecretServicePromptDismissedException();
    }

    return promptResult.result;
  }

  /// Stores a secret.
  ///
  /// Sensitive data must be stored in [secret], not [attributes].
  ///
  /// See also [storeSecret]
  Future<void> storeSecretText({
    required Map<String, String> attributes,
    required String secret,
    required String label,
    required bool replace,
    DBusObjectPath? collection,
  }) => storeSecret(
    attributes: attributes,
    secretBytes: Uint8List.fromList(utf8.encode(secret)),
    contentType: Constants.secretTextContentType,
    label: label,
    replace: replace,
    collection: collection,
  );

  /// Returns the secret matching [attributes], or `null` if no matching secret.
  ///
  /// If [collection] is omitted, the default collection is searched.
  ///
  /// Exceptions:
  ///
  /// - Propagates [DBusUnknownObjectException] if [collection] refers to an unknown
  /// D-Bus object path.
  ///
  /// - Throws [SecretServicePromptDismissedException] if a prompt was required to
  /// complete the operation and the prompt was dismissed.
  ///
  /// - Throws [SecretServiceUnlockException] if the requested collection could not
  /// be unlocked.
  ///
  /// - Throws [DuplicateSecretException] if multiple secrets match [attributes]
  /// and [duplicateStrategy] is [LookupSecretDuplicateStrategy.throwException].
  Future<SecretItem?> lookupSecret({
    required Map<String, String> attributes,
    LookupSecretDuplicateStrategy duplicateStrategy = .throwException,
    DBusObjectPath? collection,
  }) async {
    final collectionPath = collection ?? _defaultCollectionObjectPath;
    if (collectionPath == null) {
      return null;
    }

    final client = await _client;

    final collectionObject = _remoteObject(client, path: collectionPath);

    await _ensureCollectionUnlocked(
      client: client,
      objectPath: collectionPath,
      remoteObject: collectionObject,
    );

    final searchResult = await _searchItemsInCollection(
      attributes: attributes,
      collectionObject: collectionObject,
    );

    if (searchResult.isEmpty) {
      return null;
    }

    DBusObjectPath resolveItemObjectPathFromSearch() {
      if (searchResult.length > 1) {
        switch (duplicateStrategy) {
          case .throwException:
            throw DuplicateSecretException(
              attributes: attributes,
              matchCount: searchResult.length,
            );
          case .first:
            return searchResult.first;
          case .last:
            return searchResult.last;
        }
      }

      return searchResult.first;
    }

    final itemObjectPath = resolveItemObjectPathFromSearch();
    final itemObject = _remoteObject(client, path: itemObjectPath);

    await _ensureItemUnlocked(
      client: client,
      objectPath: itemObjectPath,
      remoteObject: itemObject,
    );

    final raw = await itemObject.callGetSecret(_sessionObjectPathOrThrow);

    final secretValue = SecretValue.fromDBus(raw);

    // Gets all item properties in a single D-Bus call, including Label,
    // Created, Modified, and Attributes.
    final properties = await itemObject.getAllProperties(
      'org.freedesktop.Secret.Item',
    );

    final itemAttributes = properties['Attributes']!.toStringStringMap();
    final label = properties['Label']!.asString();
    final created = properties['Created']!.asUint64();
    final modified = properties['Modified']!.asUint64();

    return SecretItem(
      attributes: itemAttributes,
      secretBytes: Uint8List.fromList(secretValue.secretBytes.toList()),
      contentType: secretValue.contentType,
      label: label,
      created: DateTime.fromMillisecondsSinceEpoch(
        created * Duration.millisecondsPerSecond,
        isUtc: true,
      ),
      modified: DateTime.fromMillisecondsSinceEpoch(
        modified * Duration.millisecondsPerSecond,
        isUtc: true,
      ),
    );
  }

  /// Deletes the secret matching [attributes].
  ///
  /// If [collection] is omitted, the default collection is searched.
  ///
  /// Exceptions:
  ///
  /// - Propagates [DBusUnknownObjectException] if [collection] refers to an unknown
  /// D-Bus object path.
  ///
  /// - Throws [DuplicateSecretException] if multiple secrets match [attributes]
  /// and [duplicateStrategy] is [DeleteSecretDuplicateStrategy.throwException].
  ///
  /// - Throws [SecretServicePromptDismissedException] if a prompt was required to
  /// complete the operation and the prompt was dismissed.
  ///
  /// - Throws [SecretServiceUnlockException] if the requested collection could not
  /// be unlocked.
  ///
  /// Returns the number of matching secrets that were found and deleted, or `0`
  /// if no matching secret exists.
  Future<int> deleteSecret({
    required Map<String, String> attributes,
    DeleteSecretDuplicateStrategy duplicateStrategy =
        DeleteSecretDuplicateStrategy.throwException,
    DBusObjectPath? collection,
  }) async {
    final collectionPath = collection ?? _defaultCollectionObjectPath;
    if (collectionPath == null) {
      return 0;
    }

    final client = await _client;

    final collectionObject = _remoteObject(client, path: collectionPath);

    await _ensureCollectionUnlocked(
      client: client,
      objectPath: collectionPath,
      remoteObject: collectionObject,
    );

    final searchResult = await _searchItemsInCollection(
      attributes: attributes,
      collectionObject: collectionObject,
    );

    if (searchResult.isEmpty) {
      return 0;
    }

    List<DBusObjectPath> resolveItemObjectPathsFromSearch() {
      if (searchResult.length > 1) {
        switch (duplicateStrategy) {
          case .throwException:
            throw DuplicateSecretException(
              attributes: attributes,
              matchCount: searchResult.length,
            );
          case .first:
            return [searchResult.first];
          case .last:
            return [searchResult.last];
          case .deleteAll:
            return searchResult;
        }
      }

      return [searchResult.first];
    }

    final itemObjectPaths = resolveItemObjectPathsFromSearch();

    for (final itemObjectPath in itemObjectPaths) {
      final itemObject = _remoteObject(client, path: itemObjectPath);

      final promptObjectPath = await itemObject.callDelete_();
      if (promptObjectPath == DBusObjectPath.root) {
        continue;
      }

      await _executePrompt(client, promptPath: promptObjectPath);

      // TODO: Should the operation-specific prompt result be validated after
      // handling a prompt returned by org.freedesktop.Secret.Item.Delete()?
      //
      // Unlike CreateItem() and Unlock(), the specification does not define
      // the prompt result for this operation:
      //
      // > An item can be deleted by calling the Delete() method on the Item interface.
      // >
      // > When deleting an item, the service may need to prompt the user for additional information. In this case, a prompt object is returned. It must be acted upon in order for the item to be deleted.
      //
      // Source: https://specifications.freedesktop.org/secret-service/latest-single/#id-1.2.4
      //
      // It is therefore unclear whether there is any operation-specific result to validate.
    }

    return itemObjectPaths.length;
  }

  /// Counts the number of items matching the given attributes.
  ///
  /// Returns `0` if no default collection is available.
  Future<int> countSecrets({
    required Map<String, String> attributes,
    DBusObjectPath? collection,
  }) async {
    final collectionPath = collection ?? _defaultCollectionObjectPath;
    if (collectionPath == null) {
      return 0;
    }

    final client = await _client;
    final collectionObject = _remoteObject(client, path: collectionPath);

    // Unlocking the collection is not required because this only searches item
    // attributes and does not access secret values or modify the collection.

    final result = await _searchItemsInCollection(
      attributes: attributes,
      collectionObject: collectionObject,
    );

    return result.length;
  }

  Future<UnlockResult> _unlock(
    DBusClient client, {
    required List<DBusObjectPath> objects,
  }) async {
    final serviceObject = _remoteObject(client);
    final result = await serviceObject.callUnlock(objects);
    return UnlockResult(
      unlocked: .unmodifiable(result[0].asObjectPathArray()),
      prompt: result[1].asObjectPath(),
    );
  }

  /// Note: closing the D-Bus client via [DBusClient.close] also closes the secret
  /// session according to:
  /// https://specifications.freedesktop.org/secret-service/latest-single/#sessions
  ///
  /// The session is closed explicitly because consumers may provide [_dbusClientProvider].
  /// In that case, the [DBusClient] is owned by the consumer and will not be closed
  /// by this class, so this class must close the session it opened.
  Future<void> _closeSession() async {
    final sessionObjectPath = _sessionObjectPath;
    if (sessionObjectPath == null) {
      return;
    }
    final client =
        _cachedClient ?? (throw StateError('DBus client is not initialized'));

    final sessionObject = _remoteObject(
      client,
      path: sessionObjectPath, // The path returned from OpenSession()
    );
    await sessionObject.callClose();
  }

  /// Closes the Secret Service session and releases resources.
  ///
  /// Call this when the instance is no longer needed, typically during
  /// application shutdown.
  ///
  /// The instance can be reused by calling [initialize] again.
  Future<void> close() async {
    try {
      await _closeSession();
    } finally {
      try {
        if (_ownsClient) {
          await _cachedClient?.close();
        }
      } finally {
        _cachedClient = null;
        _sessionObjectPath = null;
        _defaultCollectionObjectPath = null;
      }
    }
  }

  // https://specifications.freedesktop.org/secret-service/latest-single/#id-1.3.3.3.4.4.4.1
  Map<String, DBusValue> _createItemProperties({
    required String label,
    required Map<String, String> attributes,
  }) => {
    'org.freedesktop.Secret.Item.Label': DBusString(label),
    'org.freedesktop.Secret.Item.Attributes': attributes
        .toDBusStringStringMap(),
  };
}

extension on Map<String, String> {
  DBusDict toDBusStringStringMap() {
    return DBusDict(
      DBusSignature('s'),
      DBusSignature('s'),
      map((key, value) => MapEntry(DBusString(key), DBusString(value))),
    );
  }
}

extension on DBusValue {
  Map<String, String> toStringStringMap() {
    return asDict().map(
      (key, value) => MapEntry(key.asString(), value.asString()),
    );
  }
}
