/// The base exception type for exceptions thrown by this library.
///
/// All library-defined exceptions implement this type. Exceptions from
/// `package:dbus` are not wrapped or converted and may be propagated directly.
abstract interface class SecretServiceException implements Exception {}

class SecretServiceSessionNegotiationException
    implements SecretServiceException {
  const SecretServiceSessionNegotiationException({required this.algorithm});

  final String algorithm;

  @override
  String toString() =>
      'SecretServiceSessionNegotiationException: '
      'Secret Service session negotiation was not completed. '
      'The Secret Service implementation may not support the "$algorithm" algorithm.';
}

@Deprecated(
  'No longer applicable: https://github.com/EchoEllet/dart-packages/issues/2\n'
  'FreeDesktopSecret.storeSecret() now automatically creates the default '
  'collection when the collection parameter is omitted.',
)
class SecretServiceCollectionNotFoundException
    implements SecretServiceException {
  @Deprecated(
    'No longer applicable: https://github.com/EchoEllet/dart-packages/issues/2\n'
    'FreeDesktopSecret.storeSecret() now automatically creates the default '
    'collection when the collection parameter is omitted.',
  )
  const SecretServiceCollectionNotFoundException({required this.alias});

  final String alias;

  @override
  String toString() =>
      'SecretServiceCollectionNotFoundException: '
      'Secret Service collection for alias "$alias" was not found.';
}

class SecretServicePromptDismissedException implements SecretServiceException {
  const SecretServicePromptDismissedException();

  @override
  String toString() =>
      'SecretServicePromptDismissedException: '
      'The Secret Service prompt was dismissed before the operation could be completed.';
}

class SecretServiceUnlockException implements SecretServiceException {
  const SecretServiceUnlockException();

  @override
  String toString() =>
      'SecretServiceUnlockException: '
      'The requested objects were not unlocked.';
}

class UnsupportedSecretContentTypeException implements FormatException {
  const UnsupportedSecretContentTypeException(
    this.message, {
    required this.contentType,
  });

  @override
  final String message;
  final String contentType;

  @override
  String toString() => 'UnsupportedSecretContentTypeException: $message';

  @override
  int? get offset => null;

  @override
  String get source => contentType;
}

class DuplicateSecretException implements SecretServiceException {
  const DuplicateSecretException({
    required this.attributes,
    required this.matchCount,
  });

  final Map<String, String> attributes;
  final int matchCount;

  @override
  String toString() =>
      'DuplicateSecretException: '
      'Multiple secrets matched the requested attributes: $attributes\n'
      'Matching secrets: $matchCount\n'
      'Expected exactly 1.\n'
      'Hint: The duplicate strategy can be changed to control how multiple matching secrets are handled.';
}

class SecretServiceCreateItemResultException implements SecretServiceException {
  const SecretServiceCreateItemResultException();

  @override
  String toString() =>
      'SecretServiceCreateItemResultException: '
      'The Secret Service CreateItem operation returned no item object path '
      'after the prompt was completed with dismissed=false. '
      'The Secret Service implementation may have violated the specification '
      'or the item creation operation may not have been completed successfully.';
}

class SecretServiceCreateCollectionResultException
    implements SecretServiceException {
  const SecretServiceCreateCollectionResultException();

  @override
  String toString() =>
      'SecretServiceCreateCollectionResultException: '
      'The Secret Service CreateCollection operation returned no collection object path '
      'after the prompt was completed with dismissed=false. '
      'The Secret Service implementation may have violated the specification '
      'or the collection creation operation may not have been completed successfully.';
}
