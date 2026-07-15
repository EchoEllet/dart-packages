import 'package:dbus/dbus.dart';
import 'package:freedesktop_secret/src/models/prompt_result.dart';

final class CreateItemResult extends PromptResult {
  CreateItemResult({required this.item, required super.prompt});

  /// The item created, or the special value '/' if a prompt is necessary.
  final DBusObjectPath item;

  /// A prompt object, or the special value '/' if no prompt is necessary.
  @override
  DBusObjectPath get prompt => super.prompt;
}
