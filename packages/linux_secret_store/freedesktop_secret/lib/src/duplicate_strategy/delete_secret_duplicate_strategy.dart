import 'package:freedesktop_secret/src/exceptions.dart'
    show DuplicateSecretException;

/// {@template timestamp_resolution}
/// Secret Service timestamps have second resolution. Timestamp-based duplicate
/// strategies cannot distinguish between items with identical timestamps.
/// {@endtemplate}
enum DeleteSecretDuplicateStrategy {
  /// Throws [DuplicateSecretException].
  throwException,

  /// Deletes the first item returned by SearchItems.
  /// The ordering is service implementation-defined and should **not** be relied upon.
  first,

  /// Deletes the last item returned by SearchItems.
  /// The ordering is service implementation-defined and should **not** be relied upon.
  last,

  /// Deletes the item with the earliest creation timestamp.
  ///
  /// {@macro timestamp_resolution}
  oldestCreated,

  /// Deletes the item with the latest creation timestamp.
  ///
  /// {@macro timestamp_resolution}
  newestCreated,

  /// Deletes the item with the earliest modification timestamp.
  ///
  /// {@macro timestamp_resolution}
  oldestModified,

  /// Deletes the item with the latest modification timestamp.
  ///
  /// {@macro timestamp_resolution}
  newestModified,

  /// Deletes all matching secrets.
  deleteAll,
}
