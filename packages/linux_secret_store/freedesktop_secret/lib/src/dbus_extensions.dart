import 'package:dbus/dbus.dart';

extension StringStringMapToDBusDict on Map<String, String> {
  DBusDict toDBusStringStringMap() {
    return DBusDict(
      DBusSignature('s'),
      DBusSignature('s'),
      map((key, value) => MapEntry(DBusString(key), DBusString(value))),
    );
  }
}

extension DBusValueStringStringMapConversion on DBusValue {
  Map<String, String> toStringStringMap() {
    return asDict().map(
      (key, value) => MapEntry(key.asString(), value.asString()),
    );
  }
}
