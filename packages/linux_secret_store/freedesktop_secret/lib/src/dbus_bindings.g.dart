// This file was generated using the following command and may be overwritten.
// dart-dbus generate-remote-object third_party/libsecret/org.freedesktop.Secrets.xml

import 'package:dbus/dbus.dart';

/// Signal data for org.freedesktop.Secret.Service.CollectionCreated.
class OrgFreedesktopSecretsCollectionCreated extends DBusSignal {
  OrgFreedesktopSecretsCollectionCreated(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
  DBusObjectPath get collection => values[0].asObjectPath();
}

/// Signal data for org.freedesktop.Secret.Service.CollectionDeleted.
class OrgFreedesktopSecretsCollectionDeleted extends DBusSignal {
  OrgFreedesktopSecretsCollectionDeleted(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
  DBusObjectPath get collection => values[0].asObjectPath();
}

/// Signal data for org.freedesktop.Secret.Service.CollectionChanged.
class OrgFreedesktopSecretsCollectionChanged extends DBusSignal {
  OrgFreedesktopSecretsCollectionChanged(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
  DBusObjectPath get collection => values[0].asObjectPath();
}

/// Signal data for org.freedesktop.Secret.Collection.ItemCreated.
class OrgFreedesktopSecretsItemCreated extends DBusSignal {
  OrgFreedesktopSecretsItemCreated(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
  DBusObjectPath get item => values[0].asObjectPath();
}

/// Signal data for org.freedesktop.Secret.Collection.ItemDeleted.
class OrgFreedesktopSecretsItemDeleted extends DBusSignal {
  OrgFreedesktopSecretsItemDeleted(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
  DBusObjectPath get item => values[0].asObjectPath();
}

/// Signal data for org.freedesktop.Secret.Collection.ItemChanged.
class OrgFreedesktopSecretsItemChanged extends DBusSignal {
  OrgFreedesktopSecretsItemChanged(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
  DBusObjectPath get item => values[0].asObjectPath();
}

/// Signal data for org.freedesktop.Secret.Prompt.Completed.
class OrgFreedesktopSecretsCompleted extends DBusSignal {
  OrgFreedesktopSecretsCompleted(DBusSignal signal)
    : super(
        sender: signal.sender,
        path: signal.path,
        interface: signal.interface,
        name: signal.name,
        values: signal.values,
      );
  bool get dismissed => values[0].asBoolean();
  DBusValue get result => values[1].asVariant();
}

class OrgFreedesktopSecrets extends DBusRemoteObject {
  OrgFreedesktopSecrets(
    super.client,
    String destination, {
    super.path = const DBusObjectPath.unchecked('/org/freedesktop/secrets'),
  }) : super(name: destination) {
    collectionCreated =
        DBusRemoteObjectSignalStream(
          object: this,
          interface: 'org.freedesktop.Secret.Service',
          name: 'CollectionCreated',
          signature: DBusSignature('o'),
        ).asBroadcastStream().map(
          (signal) => OrgFreedesktopSecretsCollectionCreated(signal),
        );

    collectionDeleted =
        DBusRemoteObjectSignalStream(
          object: this,
          interface: 'org.freedesktop.Secret.Service',
          name: 'CollectionDeleted',
          signature: DBusSignature('o'),
        ).asBroadcastStream().map(
          (signal) => OrgFreedesktopSecretsCollectionDeleted(signal),
        );

    collectionChanged =
        DBusRemoteObjectSignalStream(
          object: this,
          interface: 'org.freedesktop.Secret.Service',
          name: 'CollectionChanged',
          signature: DBusSignature('o'),
        ).asBroadcastStream().map(
          (signal) => OrgFreedesktopSecretsCollectionChanged(signal),
        );

    itemCreated =
        DBusRemoteObjectSignalStream(
          object: this,
          interface: 'org.freedesktop.Secret.Collection',
          name: 'ItemCreated',
          signature: DBusSignature('o'),
        ).asBroadcastStream().map(
          (signal) => OrgFreedesktopSecretsItemCreated(signal),
        );

    itemDeleted =
        DBusRemoteObjectSignalStream(
          object: this,
          interface: 'org.freedesktop.Secret.Collection',
          name: 'ItemDeleted',
          signature: DBusSignature('o'),
        ).asBroadcastStream().map(
          (signal) => OrgFreedesktopSecretsItemDeleted(signal),
        );

    itemChanged =
        DBusRemoteObjectSignalStream(
          object: this,
          interface: 'org.freedesktop.Secret.Collection',
          name: 'ItemChanged',
          signature: DBusSignature('o'),
        ).asBroadcastStream().map(
          (signal) => OrgFreedesktopSecretsItemChanged(signal),
        );

    completed =
        DBusRemoteObjectSignalStream(
          object: this,
          interface: 'org.freedesktop.Secret.Prompt',
          name: 'Completed',
          signature: DBusSignature('bv'),
        ).asBroadcastStream().map(
          (signal) => OrgFreedesktopSecretsCompleted(signal),
        );
  }

  /// Stream of org.freedesktop.Secret.Service.CollectionCreated signals.
  late final Stream<OrgFreedesktopSecretsCollectionCreated> collectionCreated;

  /// Stream of org.freedesktop.Secret.Service.CollectionDeleted signals.
  late final Stream<OrgFreedesktopSecretsCollectionDeleted> collectionDeleted;

  /// Stream of org.freedesktop.Secret.Service.CollectionChanged signals.
  late final Stream<OrgFreedesktopSecretsCollectionChanged> collectionChanged;

  /// Stream of org.freedesktop.Secret.Collection.ItemCreated signals.
  late final Stream<OrgFreedesktopSecretsItemCreated> itemCreated;

  /// Stream of org.freedesktop.Secret.Collection.ItemDeleted signals.
  late final Stream<OrgFreedesktopSecretsItemDeleted> itemDeleted;

  /// Stream of org.freedesktop.Secret.Collection.ItemChanged signals.
  late final Stream<OrgFreedesktopSecretsItemChanged> itemChanged;

  /// Stream of org.freedesktop.Secret.Prompt.Completed signals.
  late final Stream<OrgFreedesktopSecretsCompleted> completed;

  /// Gets org.freedesktop.Secret.Service.Collections
  Future<List<DBusObjectPath>> getCollections() async {
    final value = await getProperty(
      'org.freedesktop.Secret.Service',
      'Collections',
      signature: DBusSignature('ao'),
    );
    return value.asObjectPathArray().toList();
  }

  /// Invokes org.freedesktop.Secret.Service.OpenSession()
  Future<List<DBusValue>> callOpenSession(
    String algorithm,
    DBusValue input, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    final result = await callMethod(
      'org.freedesktop.Secret.Service',
      'OpenSession',
      [DBusString(algorithm), DBusVariant(input)],
      replySignature: DBusSignature('vo'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues;
  }

  /// Invokes org.freedesktop.Secret.Service.CreateCollection()
  Future<List<DBusValue>> callCreateCollection(
    Map<String, DBusValue> properties,
    String alias, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    final result = await callMethod(
      'org.freedesktop.Secret.Service',
      'CreateCollection',
      [DBusDict.stringVariant(properties), DBusString(alias)],
      replySignature: DBusSignature('oo'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues;
  }

  /// Invokes org.freedesktop.Secret.Service.SearchItems()
  Future<List<DBusValue>> callSearchItems(
    Map<String, String> attributes, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    final result = await callMethod(
      'org.freedesktop.Secret.Service',
      'SearchItems',
      [
        DBusDict(
          DBusSignature('s'),
          DBusSignature('s'),
          attributes.map(
            (key, value) => MapEntry(DBusString(key), DBusString(value)),
          ),
        ),
      ],
      replySignature: DBusSignature('aoao'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues;
  }

  /// Invokes org.freedesktop.Secret.Service.Unlock()
  Future<List<DBusValue>> callUnlock(
    List<DBusObjectPath> objects, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    final result = await callMethod(
      'org.freedesktop.Secret.Service',
      'Unlock',
      [DBusArray.objectPath(objects)],
      replySignature: DBusSignature('aoo'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues;
  }

  /// Invokes org.freedesktop.Secret.Service.Lock()
  Future<List<DBusValue>> callLock(
    List<DBusObjectPath> objects, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    final result = await callMethod(
      'org.freedesktop.Secret.Service',
      'Lock',
      [DBusArray.objectPath(objects)],
      replySignature: DBusSignature('aoo'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues;
  }

  /// Invokes org.freedesktop.Secret.Service.GetSecrets()
  Future<Map<DBusObjectPath, List<DBusValue>>> callGetSecrets(
    List<DBusObjectPath> items,
    DBusObjectPath session, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    final result = await callMethod(
      'org.freedesktop.Secret.Service',
      'GetSecrets',
      [DBusArray.objectPath(items), session],
      replySignature: DBusSignature('a{o(oayays)}'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asDict().map(
      (key, value) => MapEntry(key.asObjectPath(), value.asStruct()),
    );
  }

  /// Invokes org.freedesktop.Secret.Service.ReadAlias()
  Future<DBusObjectPath> callReadAlias(
    String name, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    final result = await callMethod(
      'org.freedesktop.Secret.Service',
      'ReadAlias',
      [DBusString(name)],
      replySignature: DBusSignature('o'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.Secret.Service.SetAlias()
  Future<void> callSetAlias(
    String name,
    DBusObjectPath collection, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    await callMethod(
      'org.freedesktop.Secret.Service',
      'SetAlias',
      [DBusString(name), collection],
      replySignature: DBusSignature(''),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
  }

  /// Gets org.freedesktop.Secret.Collection.Items
  Future<List<DBusObjectPath>> getItems() async {
    final value = await getProperty(
      'org.freedesktop.Secret.Collection',
      'Items',
      signature: DBusSignature('ao'),
    );
    return value.asObjectPathArray().toList();
  }

  /// Gets org.freedesktop.Secret.Collection.Label
  Future<String> getLabel() async {
    final value = await getProperty(
      'org.freedesktop.Secret.Collection',
      'Label',
      signature: DBusSignature('s'),
    );
    return value.asString();
  }

  /// Sets org.freedesktop.Secret.Collection.Label
  Future<void> setLabel(String value) async {
    await setProperty(
      'org.freedesktop.Secret.Collection',
      'Label',
      DBusString(value),
    );
  }

  /// Gets org.freedesktop.Secret.Collection.Locked
  Future<bool> getLocked() async {
    final value = await getProperty(
      'org.freedesktop.Secret.Collection',
      'Locked',
      signature: DBusSignature('b'),
    );
    return value.asBoolean();
  }

  /// Gets org.freedesktop.Secret.Collection.Created
  Future<int> getCreated() async {
    final value = await getProperty(
      'org.freedesktop.Secret.Collection',
      'Created',
      signature: DBusSignature('t'),
    );
    return value.asUint64();
  }

  /// Gets org.freedesktop.Secret.Collection.Modified
  Future<int> getModified() async {
    final value = await getProperty(
      'org.freedesktop.Secret.Collection',
      'Modified',
      signature: DBusSignature('t'),
    );
    return value.asUint64();
  }

  /// Invokes org.freedesktop.Secret.Collection.Delete()
  Future<DBusObjectPath> callDelete({
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    final result = await callMethod(
      'org.freedesktop.Secret.Collection',
      'Delete',
      [],
      replySignature: DBusSignature('o'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.Secret.Collection.SearchItems()
  Future<List<DBusObjectPath>> callSearchItems_(
    Map<String, String> attributes, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    final result = await callMethod(
      'org.freedesktop.Secret.Collection',
      'SearchItems',
      [
        DBusDict(
          DBusSignature('s'),
          DBusSignature('s'),
          attributes.map(
            (key, value) => MapEntry(DBusString(key), DBusString(value)),
          ),
        ),
      ],
      replySignature: DBusSignature('ao'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asObjectPathArray().toList();
  }

  /// Invokes org.freedesktop.Secret.Collection.CreateItem()
  Future<List<DBusValue>> callCreateItem(
    Map<String, DBusValue> properties,
    List<DBusValue> secret,
    bool replace, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    final result = await callMethod(
      'org.freedesktop.Secret.Collection',
      'CreateItem',
      [
        DBusDict.stringVariant(properties),
        DBusStruct(secret),
        DBusBoolean(replace),
      ],
      replySignature: DBusSignature('oo'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues;
  }

  /// Gets org.freedesktop.Secret.Item.Locked
  Future<bool> getLocked_() async {
    final value = await getProperty(
      'org.freedesktop.Secret.Item',
      'Locked',
      signature: DBusSignature('b'),
    );
    return value.asBoolean();
  }

  /// Gets org.freedesktop.Secret.Item.Attributes
  Future<Map<String, String>> getAttributes() async {
    final value = await getProperty(
      'org.freedesktop.Secret.Item',
      'Attributes',
      signature: DBusSignature('a{ss}'),
    );
    return value.asDict().map(
      (key, value) => MapEntry(key.asString(), value.asString()),
    );
  }

  /// Sets org.freedesktop.Secret.Item.Attributes
  Future<void> setAttributes(Map<String, String> value) async {
    await setProperty(
      'org.freedesktop.Secret.Item',
      'Attributes',
      DBusDict(
        DBusSignature('s'),
        DBusSignature('s'),
        value.map((key, value) => MapEntry(DBusString(key), DBusString(value))),
      ),
    );
  }

  /// Gets org.freedesktop.Secret.Item.Label
  Future<String> getLabel_() async {
    final value = await getProperty(
      'org.freedesktop.Secret.Item',
      'Label',
      signature: DBusSignature('s'),
    );
    return value.asString();
  }

  /// Sets org.freedesktop.Secret.Item.Label
  Future<void> setLabel_(String value) async {
    await setProperty(
      'org.freedesktop.Secret.Item',
      'Label',
      DBusString(value),
    );
  }

  /// Gets org.freedesktop.Secret.Item.Created
  Future<int> getCreated_() async {
    final value = await getProperty(
      'org.freedesktop.Secret.Item',
      'Created',
      signature: DBusSignature('t'),
    );
    return value.asUint64();
  }

  /// Gets org.freedesktop.Secret.Item.Modified
  Future<int> getModified_() async {
    final value = await getProperty(
      'org.freedesktop.Secret.Item',
      'Modified',
      signature: DBusSignature('t'),
    );
    return value.asUint64();
  }

  /// Invokes org.freedesktop.Secret.Item.Delete()
  Future<DBusObjectPath> callDelete_({
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    final result = await callMethod(
      'org.freedesktop.Secret.Item',
      'Delete',
      [],
      replySignature: DBusSignature('o'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asObjectPath();
  }

  /// Invokes org.freedesktop.Secret.Item.GetSecret()
  Future<List<DBusValue>> callGetSecret(
    DBusObjectPath session, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    final result = await callMethod(
      'org.freedesktop.Secret.Item',
      'GetSecret',
      [session],
      replySignature: DBusSignature('(oayays)'),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return result.returnValues[0].asStruct();
  }

  /// Invokes org.freedesktop.Secret.Item.SetSecret()
  Future<void> callSetSecret(
    List<DBusValue> secret, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    await callMethod(
      'org.freedesktop.Secret.Item',
      'SetSecret',
      [DBusStruct(secret)],
      replySignature: DBusSignature(''),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
  }

  /// Invokes org.freedesktop.Secret.Session.Close()
  Future<void> callClose({
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    await callMethod(
      'org.freedesktop.Secret.Session',
      'Close',
      [],
      replySignature: DBusSignature(''),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
  }

  /// Invokes org.freedesktop.Secret.Prompt.Prompt()
  Future<void> callPrompt(
    String windowId, {
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    await callMethod(
      'org.freedesktop.Secret.Prompt',
      'Prompt',
      [DBusString(windowId)],
      replySignature: DBusSignature(''),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
  }

  /// Invokes org.freedesktop.Secret.Prompt.Dismiss()
  Future<void> callDismiss({
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) async {
    await callMethod(
      'org.freedesktop.Secret.Prompt',
      'Dismiss',
      [],
      replySignature: DBusSignature(''),
      noAutoStart: noAutoStart,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
  }
}
