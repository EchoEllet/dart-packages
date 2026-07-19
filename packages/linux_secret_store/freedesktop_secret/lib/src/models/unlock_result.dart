import 'package:dbus/dbus.dart';
import 'package:freedesktop_secret/src/models/prompt_result.dart';

final class UnlockResult extends PromptResult {
  const UnlockResult({required this.unlocked, required super.prompt});

  factory UnlockResult.fromDBus(List<DBusValue> raw) {
    return UnlockResult(
      unlocked: .unmodifiable(raw[0].asObjectPathArray()),
      prompt: raw[1].asObjectPath(),
    );
  }

  /// Objects that were unlocked without a prompt.
  final List<DBusObjectPath> unlocked;

  /// A prompt object which can be used to unlock the remaining objects,
  /// or the special value '/' when no prompt is necessary.
  @override
  DBusObjectPath get prompt => super.prompt;
}
