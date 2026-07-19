import 'package:dbus/dbus.dart';
import 'package:freedesktop_secret/src/dbus_extensions.dart';

final class ItemProperties {
  const ItemProperties({
    required this.attributes,
    required this.label,
    required this.created,
    required this.modified,
  });

  factory ItemProperties.fromDBus(Map<String, DBusValue> raw) {
    final storedAttributes = raw['Attributes']!.toStringStringMap();
    final label = raw['Label']!.asString();
    final created = raw['Created']!.asUint64();
    final modified = raw['Modified']!.asUint64();

    return ItemProperties(
      attributes: storedAttributes,
      label: label,
      created: DateTime.fromMillisecondsSinceEpoch(
        created * Duration.millisecondsPerSecond,
        isUtc: true,
      ),
      modified: DateTime.fromMillisecondsSinceEpoch(
        modified * Duration.millisecondsPerSecond,
        isUtc: true,
      ),
    );
  }

  /// The stored attributes are not necessarily the same as the lookup attributes.
  final Map<String, String> attributes;
  final String label;
  final DateTime created;
  final DateTime modified;
}
