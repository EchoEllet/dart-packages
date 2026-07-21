// ignore_for_file: avoid_print

import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';
import 'package:xdg_secret_portal_store/xdg_secret_portal_store.dart';

void main() async {
  final portal = XdgDesktopPortalClient();

  try {
    final store = XdgSecretPortalStore(
      secretRetriever: portal.secret.retrieveSecret,
    );
    await store.loadMasterSecret();

    final secrets = await store.read();

    print('Secrets: $secrets');

    secrets['password'] = '12345678';

    await store.write(secrets);

    print('Password has been updated.');
  } finally {
    await portal.close();
  }
}
