import 'package:dbus/dbus.dart';

final class OpenSecretSession {
  const OpenSecretSession({required this.output, required this.objectPath});

  /// Output of the session algorithm negotiation.
  final DBusValue output;

  /// The object path of the session, if session was created.
  /// The object path '/' is returned from OpenSession() when session negotiation is incomplete.
  final DBusObjectPath objectPath;
}
