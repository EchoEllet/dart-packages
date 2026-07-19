import 'package:freedesktop_secret/src/exceptions.dart'
    show DuplicateSecretException;

enum DeleteSecretDuplicateStrategy {
  /// Throws [DuplicateSecretException].
  throwException,

  /// Deletes the first item returned by SearchItems.
  /// The ordering is service implementation-defined and should **not** be relied upon.
  first,

  /// Deletes the last item returned by SearchItems.
  /// The ordering is service implementation-defined and should **not** be relied upon.
  last,

  /// Deletes all matching secrets.
  deleteAll,
}
