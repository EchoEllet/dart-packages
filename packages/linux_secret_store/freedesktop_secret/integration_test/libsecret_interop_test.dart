@TestOn('vm && linux')
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:freedesktop_secret/freedesktop_secret.dart';
import 'package:test/test.dart';

import 'helpers.dart';
import 'libsecret_interop.dart';

/// Integration tests verifying interoperability with GNOME libsecret.
///
/// Requires:
///   - `secret-tool` CLI (provided by GNOME libsecret).
///   - A running Secret Service implementation.
void main() {
  late FreeDesktopSecret client;
  late LibsecretInterop libsecret;

  setUp(() async {
    client = FreeDesktopSecret();
    libsecret = const LibsecretInteropSecretTool();

    await client.initialize();

    await deleteAllTestSecrets(client: client);
  });

  tearDown(() async {
    await client.close();
  });

  tearDownAll(() async {
    final cleanupClient = FreeDesktopSecret();

    try {
      await cleanupClient.initialize();
      await deleteAllTestSecrets(client: cleanupClient);
    } finally {
      await cleanupClient.close();
    }
  });

  const testLabel = 'Test Secret';
  const testSecret = '123';

  final Map<String, String> sampleAttributes = testAttributes({
    'service': 'dummy-app',
    'account': 'test-user',
  });

  /// Stores a UTF-8 text secret for interoperability tests.
  ///
  /// This helper intentionally uses `text/plain` instead of
  /// `text/plain; charset=utf-8` as a temporary workaround for a
  /// `secret-tool lookup` limitation. The libsecret C API accepts both content
  /// types, but current versions of `secret-tool lookup` reject
  /// `text/plain; charset=utf-8`.
  ///
  /// Tracking issue:
  /// https://gitlab.gnome.org/GNOME/libsecret/-/work_items/114
  ///
  /// Open merge request:
  /// https://gitlab.gnome.org/GNOME/libsecret/-/merge_requests/175
  ///
  /// Remove this helper once the fix is widely available.
  ///
  /// See also: https://pub.dev/packages/freedesktop_secret#known-secret-tool-lookup-cli-issue-gnome-libsecret
  Future<void> storeSecretText({
    required Map<String, String> attributes,
    required String secret,
    required String label,
    required bool replace,
  }) {
    return client.storeSecret(
      attributes: attributes,
      secretBytes: Uint8List.fromList(utf8.encode(secret)),
      contentType: 'text/plain',
      label: label,
      replace: replace,
    );
  }

  group('GNOME libsecret -> FreeDesktopSecret', () {
    test('store -> lookup', () async {
      final attributes = sampleAttributes;

      await libsecret.store(
        label: testLabel,
        secret: testSecret,
        attributes: attributes,
      );

      final item = await client.lookupSecret(attributes: attributes);

      expect(item, isNotNull);
      expect(item!.label, testLabel);
      expect(item.secretAsText(), testSecret);
      expect(item.attributes, attributes);
    });

    // test('store -> search', () async {
    //   final attributes = testSecretAttributes();

    //   await libsecret.store(
    //     label: testLabel,
    //     secret: testSecret,
    //     attributes: attributes,
    //   );

    //   // TODO: Uncomment this test once searchSecrets/lookupSecrets is implemented in FreeDesktopSecret
    //   final items = await client.searchSecrets(attributes: attributes);

    //   expect(items, hasLength(1));

    //   final item = items.single;

    //   expect(item.label, testLabel);
    //   expect(item.secretText, testSecret);
    //   expect(item.attributes, attributes);
    // });

    test('store -> delete', () async {
      final attributes = sampleAttributes;

      await libsecret.store(
        label: testLabel,
        secret: testSecret,
        attributes: attributes,
      );

      final deleted = await client.deleteSecret(attributes: attributes);

      expect(deleted, 1);
      expect(await libsecret.lookup(attributes: attributes), isNull);
    });
  });

  group('FreeDesktopSecret -> GNOME libsecret', () {
    test('store -> lookup', () async {
      final attributes = sampleAttributes;

      await storeSecretText(
        attributes: attributes,
        secret: testSecret,
        label: testLabel,
        replace: true,
      );

      final secret = await libsecret.lookup(attributes: attributes);

      expect(secret, testSecret);
    });

    test('store -> search', () async {
      final attributes = sampleAttributes;

      await storeSecretText(
        attributes: attributes,
        secret: testSecret,
        label: testLabel,
        replace: true,
      );

      final items = await libsecret.search(attributes: attributes);

      expect(items, hasLength(1));

      final item = items.single;

      expect(item.label, testLabel);
      expect(item.secret, testSecret);

      // "secret-tool search" CLI does not include all attributes in its output for some
      // items (with or without the xdg:schema attribute), so we cannot reliably
      // verify the complete attribute map through this CLI implementation.
      // A more reliable solution would be using GNOME libsecret directly via FFI,
      // but this requires a C wrapper/shim due to the GObject-based API and is not
      // worth the added complexity for this integration test.
      // expect(item.attributes, attributes);

      // WORKAROUND: Verify only xdg:schema because "secret-tool search" exposes it
      // using a special "schema" field instead of "attribute.xdg:schema".
      expect(item.attributes['xdg:schema'], attributes['xdg:schema']);
    });

    test('store -> delete', () async {
      final attributes = sampleAttributes;

      await storeSecretText(
        attributes: attributes,
        secret: testSecret,
        label: testLabel,
        replace: true,
      );

      await libsecret.clear(attributes: attributes);

      expect(await client.lookupSecret(attributes: attributes), isNull);
    });
  });
}
