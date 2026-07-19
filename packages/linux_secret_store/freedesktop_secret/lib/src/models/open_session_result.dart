import 'package:dbus/dbus.dart';

final class OpenSecretSession {
  const OpenSecretSession({required this.output, required this.objectPath});

  factory OpenSecretSession.fromDBus(List<DBusValue> raw) {
    return OpenSecretSession(output: raw[0], objectPath: raw[1].asObjectPath());
  }

  /// Output of the session algorithm negotiation.
  final DBusValue output;

  /// The object path of the session, if session was created.
  /// The object path '/' is returned from OpenSession() when session negotiation is incomplete.
  final DBusObjectPath objectPath;
}
