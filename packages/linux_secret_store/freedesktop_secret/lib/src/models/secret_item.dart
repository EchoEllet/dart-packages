import 'dart:convert';
import 'dart:typed_data';

import 'package:freedesktop_secret/src/constants.dart';
import 'package:freedesktop_secret/src/exceptions.dart'
    show UnsupportedSecretContentTypeException;

final class SecretItem {
  SecretItem({
    required this.attributes,
    required this.secretBytes,
    required this.contentType,
    required this.label,
    required this.created,
    required this.modified,
  });

  final Map<String, String> attributes;
  final Uint8List secretBytes;
  final String contentType;
  final String label;

  /// The time when the secret was created.
  ///
  /// {@template secret_service_timestamp_resolution}
  /// Note: Secret Service timestamps have second resolution. Multiple items may
  /// share the same timestamp.
  /// {@endtemplate}
  final DateTime created;

  /// The time when the secret was last modified.
  ///
  /// {@macro secret_service_timestamp_resolution}
  final DateTime modified;

  /// Decodes the secret bytes as UTF-8 text.
  ///
  /// Secret values are stored as bytes and may contain arbitrary data.
  /// This method supports secrets stored as `text/plain` UTF-8 text.
  ///
  /// Throws [UnsupportedSecretContentTypeException] if the content type or
  /// charset is unsupported.
  ///
  /// Propagates [FormatException] if the bytes are not valid UTF-8.
  String secretAsText() {
    final parts = contentType.split(';').map((e) => e.trim());
    final mediaType = parts.first.toLowerCase();

    if (mediaType != 'text/plain') {
      throw UnsupportedSecretContentTypeException(
        'Secret content type is "$contentType", not "${Constants.secretTextContentType}" or "text/plain".',
        contentType: contentType,
      );
    }

    for (final parameter in parts.skip(1)) {
      final parameterParts = parameter.split('=');

      if (parameterParts.length == 2) {
        final attributeName = parameterParts[0].trim().toLowerCase();
        final attributeValue = parameterParts[1].trim().toLowerCase();

        if (attributeName == 'charset' &&
            attributeValue != 'utf-8' &&
            attributeValue != 'utf8') {
          throw UnsupportedSecretContentTypeException(
            'Unsupported text charset "$attributeValue" in content type "$contentType".',
            contentType: contentType,
          );
        }
      }
    }

    return utf8.decode(secretBytes);
  }
}
