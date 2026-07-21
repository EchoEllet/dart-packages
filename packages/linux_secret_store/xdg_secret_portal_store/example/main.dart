// ignore_for_file: avoid_print

import 'dart:io';

import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';
import 'package:xdg_directories/xdg_directories.dart';
import 'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';

void main() async {
  final portal = XdgDesktopPortalClient();

  try {
    final file = File(
      '${dataHome.path}/org.example.xdg_secret_portal_store_example/xdg_secret_portal_store/secrets.json',
    );

    final store = XdgSecretPortalStore(
      secretRetriever: portal.secret.retrieveSecret,
      persistence: SecretStorePersistenceFile(file),
    );
    await store.loadMasterSecret();

    final secrets = await store.read();

    print('Secrets: $secrets');

    secrets['password'] = '12345678';
    secrets['refresh_token'] = '...';
    secrets['access_token'] = '...';

    await store.write(secrets);

    print('Password has been updated.');
  } finally {
    await portal.close();
  }
}
