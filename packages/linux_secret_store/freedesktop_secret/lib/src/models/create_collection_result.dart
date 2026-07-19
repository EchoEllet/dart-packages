import 'package:dbus/dbus.dart';
import 'package:freedesktop_secret/src/models/prompt_result.dart';

final class CreateCollectionResult extends PromptResult {
  CreateCollectionResult({required this.collection, required super.prompt});

  factory CreateCollectionResult.fromDBus(List<DBusValue> raw) {
    return CreateCollectionResult(
      collection: raw[0].asObjectPath(),
      prompt: raw[1].asObjectPath(),
    );
  }

  /// The new collection object, or '/' if prompting is necessary.
  final DBusObjectPath collection;

  /// A prompt object if prompting is necessary, or '/' if no prompt was needed.
  @override
  DBusObjectPath get prompt => super.prompt;
}
