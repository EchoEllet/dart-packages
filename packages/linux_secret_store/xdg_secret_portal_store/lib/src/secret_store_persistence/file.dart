import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show File;

import 'package:xdg_directories/xdg_directories.dart';
import 'package:xdg_secret_portal_store/src/encrypted_secret_store.dart';
import 'package:xdg_secret_portal_store/src/secret_store_persistence/interface.dart';

/// File-based [SecretStorePersistence] implementation.
///
/// Uses `$XDG_DATA_HOME/xdg_secret_portal_store/secrets.json` by default.
class SecretStorePersistenceFile implements SecretStorePersistence {
  SecretStorePersistenceFile([File? file]) : _file = file ?? _defaultFile;

  final File _file;

  static File get _defaultFile =>
      File('${dataHome.path}/xdg_secret_portal_store/secrets.json');

  @override
  Future<EncryptedSecretStore?> read() async {
    if (!_file.existsSync()) {
      return null;
    }

    final content = await _file.readAsString();

    return EncryptedSecretStore.fromJson(
      jsonDecode(content) as Map<String, Object?>,
    );
  }

  @override
  Future<void> write(EncryptedSecretStore store) async {
    await _file.parent.create(recursive: true);

    await _file.writeAsString(jsonEncode(store.toJson()));
  }
}
