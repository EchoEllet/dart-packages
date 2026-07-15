// ignore_for_file: avoid_print

import 'package:freedesktop_secret/freedesktop_secret.dart';

void main() async {
  final client = FreeDesktopSecret();

  await client.initialize();

  try {
    final lookupAttributes = {'key': 'refresh_token', 'userId': '1'};

    await client.storeSecretText(
      attributes: lookupAttributes,
      secret: '123',
      label: 'User Refresh Token',
      replace: true,
    );

    print('Stored the secret');

    final secret = await client.lookupSecret(
      attributes: lookupAttributes,
      duplicateStrategy: .first,
    );

    print('Lookup secret: ${secret?.secretAsText()}');

    final deleteResult = await client.deleteSecret(
      attributes: lookupAttributes,
    );

    if (deleteResult == 1) {
      print('Deleted the secret');
    } else if (deleteResult > 1) {
      print('Deleted $deleteResult secrets');
    }
  } finally {
    await client.close();
  }
}
