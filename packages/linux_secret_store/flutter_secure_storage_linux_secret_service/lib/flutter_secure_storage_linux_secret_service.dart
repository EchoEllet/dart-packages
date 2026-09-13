import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:freedesktop_secret/freedesktop_secret.dart';
import 'package:linux_application_id/linux_application_id.dart';

typedef _StorageMap = Map<String, String>;

/// A Linux implementation of [FlutterSecureStoragePlatform] using the
/// Secret Service API ([`org.freedesktop.secrets`](https://specifications.freedesktop.org/secret-service/latest-single/)).
class FlutterSecureStorageLinuxSecretService
    extends FlutterSecureStoragePlatform {
  /// Registers this class as the default instance of [FlutterSecureStoragePlatform].
  static void registerWith() {
    FlutterSecureStoragePlatform.instance =
        FlutterSecureStorageLinuxSecretService();
  }

  /// Secret Service client (`org.freedesktop.secrets`).
  final FreeDesktopSecret _client = FreeDesktopSecret();

  /// Overrides the Linux application ID.
  ///
  /// If null, the application ID of the running GLib `GApplication` is used.
  ///
  /// The application ID is used for the `xdg:schema` attribute of stored secrets
  /// and for migrating legacy secrets.
  String? applicationIdOverride;
  late String _applicationId;

  Future<void>? _initialization;
  Future<void> _initialize() async {
    _applicationId =
        applicationIdOverride ??
        linuxApplicationId() ??
        (throw UnsupportedError(
          'No Linux application ID is available. This must be called from a running Flutter Linux application.',
        ));

    await _client.initialize();

    if (migrateLegacyData) {
      await _migrateLegacyDataIfNeeded();
    }
  }

  /// Automatically migrates data affected by [a historical bug](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1181).
  ///
  /// See [_legacyLookupAttributes] for details.
  bool migrateLegacyData = true;

  /// Deletes the legacy secret after a successful migration.
  ///
  /// Defaults to `false` for consistency with the `flutter_secure_storage_linux` behavior:
  /// https://github.com/juliansteenbakker/flutter_secure_storage/blob/fe7232b194ed7ab815c8fda59997fccc840844f4/flutter_secure_storage_linux/linux/include/Secret.hpp#L312-L313
  bool deleteLegacyData = false;

  /// Migrates legacy data if needed.
  ///
  /// See [_legacyLookupAttributes] for details.
  Future<void> _migrateLegacyDataIfNeeded() async {
    final secretCount = await _client.countSecrets(
      attributes: _lookupAttributes(),
    );
    if (secretCount > 0) {
      // A new-format secret already exists. Preserve it and skip migration.
      return;
    }

    final legacyAttributes = _legacyLookupAttributes();
    final legacySecret = await _client.lookupSecret(
      attributes: legacyAttributes,
      duplicateStrategy: .newestCreated,
    );
    if (legacySecret == null) {
      return;
    }

    await _writeStorageMap(legacySecret.storageMap());

    if (deleteLegacyData) {
      await _client.deleteSecret(
        attributes: legacyAttributes,
        duplicateStrategy: .newestCreated,
      );
    }
  }

  Future<void> _ensureInitialized() => _initialization ??= _initialize();

  /// Used to migrate data affected by [a historical bug](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1181).
  ///
  /// The attribute `xdg:schema` is intentionally excluded here.
  ///
  /// Older versions of `flutter_secure_storage_linux` incorrectly
  /// populated the `xdg:schema` attribute with unstable yet unique values (for example,
  /// `*` or `9`). Instead, we match only on the application-specific
  /// `account` attribute, which was populated consistently, to preserve
  /// compatibility with existing data.
  ///
  /// `flutter_secure_storage_linux` (the upstream implementation) was updated
  /// in [4.0.0-beta.1](https://pub.dev/packages/flutter_secure_storage_linux/versions/4.0.0-beta.1/changelog)
  /// to fix this issue and migrate data affected by it:
  /// https://github.com/juliansteenbakker/flutter_secure_storage/pull/1249
  Map<String, String> _legacyLookupAttributes() => {
    'account': '$_applicationId.secureStorage',
  };

  Map<String, String> _lookupAttributes() => {
    'xdg:schema': '$_applicationId/FlutterSecureStorage',
    'account': '$_applicationId.secureStorage',
  };

  /// Reads and decodes the stored key/value map.
  Future<_StorageMap> _readStorageMap() async {
    final secret = await _client.lookupSecret(
      attributes: _lookupAttributes(),
      duplicateStrategy: .first,
    );
    return secret == null ? {} : secret.storageMap();
  }

  /// Encodes and stores the key/value map.
  Future<void> _writeStorageMap(_StorageMap map) async {
    await _client.storeSecretText(
      attributes: _lookupAttributes(),
      label: '$_applicationId/FlutterSecureStorage',
      secret: jsonEncode(map),
      replace: true,
    );
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async {
    await _ensureInitialized();

    final map = await _readStorageMap();
    return map.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    await _ensureInitialized();

    final map = await _readStorageMap();
    map.remove(key);

    await _writeStorageMap(map);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    await _ensureInitialized();

    await _writeStorageMap({});
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    await _ensureInitialized();

    final map = await _readStorageMap();
    return map[key];
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async {
    await _ensureInitialized();

    return _readStorageMap();
  }

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    await _ensureInitialized();

    final map = await _readStorageMap();
    map[key] = value;

    await _writeStorageMap(map);
  }
}

extension on SecretItem {
  /// Decodes the stored key/value map.
  _StorageMap storageMap() =>
      (jsonDecode(secretAsText()) as Map<String, Object?>).cast();
}
