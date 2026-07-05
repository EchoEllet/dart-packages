import 'package:json_safe/src/types.dart';

sealed class JsonParseException implements Exception {
  const JsonParseException(this.message);

  final String message;
}

/// Occurs while decoding the JSON String. Indicates invalid or malformed JSON.
final class JsonDecodingException extends JsonParseException
    implements FormatException {
  const JsonDecodingException({
    required this.source,
    required this.reason,
    this.offset,
  }) : super(
         'JSON decoding failed. Reason: $reason\n'
         'Input: $source',
       );

  /// The actual source input which caused the error (raw JSON).
  @override
  final String source;

  final String reason;

  /// The offset in [source] where the error was detected.
  ///
  /// See also [FormatException.offset]
  @override
  final int? offset;

  @override
  String toString() => '$JsonDecodingException: $message';
}

/// Occurs while deserializing a decoded JSON object.
/// Indicates a structural or type mismatch between JSON and the expected model.
final class JsonDeserializationException extends JsonParseException {
  const JsonDeserializationException({
    required this.decodedJson,
    required this.reason,
  }) : super(
         'JSON deserialization failed. Reason: $reason\n'
         'Decoded JSON: $decodedJson',
       );

  final JsonMap decodedJson;
  final String reason;

  @override
  String toString() => '$JsonDeserializationException: $message';
}

/// Occurs when a valid JSON value is not a JSON object ([JsonMap]).
///
/// Expected a JSON object, but got a different JSON type instead.
final class JsonObjectExpectedException extends JsonParseException {
  const JsonObjectExpectedException(this.source, this.actualType)
    : super(
        'Expected a JSON object ($JsonMap) but got $actualType.\n'
        'Input: $source',
      );

  /// The actual source input which caused the error (raw JSON).
  final String source;

  final Type actualType;

  @override
  String toString() => '$JsonObjectExpectedException: $message';
}
