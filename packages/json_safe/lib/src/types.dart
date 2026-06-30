/// Represents a JSON value.
///
/// Can be:
/// - `String`
/// - `num` (`int` or `double`)
/// - `bool`
/// - `null`
/// - `List<JsonValue>` (or `List<dynamic>`)
/// - `Map<String, JsonValue>`
///
/// Note: This typedef does not enforce this constraint.
typedef JsonValue = Object?;

/// The type definition for a JSON-serializable [Map].
typedef JsonMap = Map<String, JsonValue>;

/// The type definition for a JSON-serializable [List].
typedef JsonList = List<JsonValue>;
