import 'package:freedesktop_secret/src/exceptions.dart'
    show DuplicateSecretException;

enum DeleteSecretDuplicateStrategy {
  /// Throws [DuplicateSecretException].
  throwException,

  /// Deletes the first matching secret.
  first,

  /// Deletes the last matching secret.
  last,

  /// Deletes all matching secrets.
  deleteAll,
}
