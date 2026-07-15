import 'package:dbus/dbus.dart';

abstract base class PromptResult {
  const PromptResult({required this.prompt});

  /// A prompt object, or the special value '/' when no prompt is necessary.
  final DBusObjectPath prompt;

  bool get promptRequired => prompt != DBusObjectPath.root;
}
