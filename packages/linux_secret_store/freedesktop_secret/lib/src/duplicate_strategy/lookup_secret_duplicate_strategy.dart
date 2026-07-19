import 'package:freedesktop_secret/src/exceptions.dart'
    show DuplicateSecretException;

enum LookupSecretDuplicateStrategy {
  /// Throws [DuplicateSecretException].
  throwException,

  /// Returns the first item returned by SearchItems.
  /// The ordering is service implementation-defined and should **not** be relied upon.
  first,

  /// Returns the last item returned by SearchItems.
  /// The ordering is service implementation-defined and should **not** be relied upon.
  last,
}
