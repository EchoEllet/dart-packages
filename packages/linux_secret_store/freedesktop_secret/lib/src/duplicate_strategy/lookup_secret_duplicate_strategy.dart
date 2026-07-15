import 'package:freedesktop_secret/src/exceptions.dart'
    show DuplicateSecretException;

enum LookupSecretDuplicateStrategy {
  /// Throws [DuplicateSecretException].
  throwException,

  /// Returns the first matching secret.
  first,

  /// Returns the last matching secret.
  last,
}
