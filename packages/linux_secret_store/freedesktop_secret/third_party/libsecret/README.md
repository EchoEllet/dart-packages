To generate Dart D-Bus bindings from XML introspection:

```shell
dart run dbus:dart_dbus generate-remote-object third_party/libsecret/org.freedesktop.Secrets.xml > lib/src/dbus_bindings.g.dart
```
