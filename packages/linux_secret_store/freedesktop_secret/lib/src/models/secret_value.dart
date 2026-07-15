import 'package:dbus/dbus.dart';

// https://specifications.freedesktop.org/secret-service/latest-single/#type-Secret
final class SecretValue {
  const SecretValue({
    required this.session,
    required this.parameters,
    required this.secretBytes,
    required this.contentType,
  });

  factory SecretValue.fromDBus(List<DBusValue> values) {
    return SecretValue(
      session: values[0].asObjectPath(),
      parameters: values[1].asByteArray(),
      secretBytes: values[2].asByteArray(),
      contentType: values[3].asString(),
    );
  }

  List<DBusValue> toDBus() {
    return [
      session,
      DBusArray.byte(parameters),
      DBusArray.byte(secretBytes),
      DBusString(contentType),
    ];
  }

  /// The session that was used to encode the secret.
  final DBusObjectPath session;

  /// Algorithm dependent parameters for secret value encoding.
  final Iterable<int> parameters;

  /// Possibly encoded secret value
  final Iterable<int> secretBytes;

  /// The content type of the secret. For example: 'text/plain; charset=utf8'
  final String contentType;
}
