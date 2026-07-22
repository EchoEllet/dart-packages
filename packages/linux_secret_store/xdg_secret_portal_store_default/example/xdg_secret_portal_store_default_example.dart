// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';
import 'package:xdg_secret_portal_store_default/xdg_secret_portal_store_default.dart';

// Not a real example. Exists to satisfy pub static analysis.
// The complete example is in package:xdg_secret_portal_store/example

void main() async {
  XdgSecretPortalStore(
    secretRetriever: ({String? token}) async => Uint8List.fromList([]),
    persistence: SecretStorePersistenceFile(File('')),
    crypto: SecretStoreCryptoDefault(),
  );
}
