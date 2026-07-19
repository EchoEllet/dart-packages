import 'package:dbus/dbus.dart';
import 'package:freedesktop_secret/src/models/prompt_result.dart';

final class CreateItemResult extends PromptResult {
  CreateItemResult({required this.item, required super.prompt});

  factory CreateItemResult.fromDBus(List<DBusValue> raw) {
    return CreateItemResult(
      item: raw[0].asObjectPath(),
      prompt: raw[1].asObjectPath(),
    );
  }

  /// The item created, or the special value '/' if a prompt is necessary.
  final DBusObjectPath item;

  /// A prompt object, or the special value '/' if no prompt is necessary.
  @override
  DBusObjectPath get prompt => super.prompt;
}
