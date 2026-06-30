import 'package:json_safe/src/types.dart';

sealed class JsonParseException implements Exception {
  const JsonParseException(this.message);

  final String message;
}

/// Occurs while decoding the JSON String. Indicates invalid or malformed JSON.
final class JsonDecodingException extends FormatException
    implements JsonParseException {
  const JsonDecodingException(String jsonInput, this.reason)
    : super('JSON decoding failed. Reason: $reason\nInput: $jsonInput');
  final String reason;

  @override
  String toString() => '$JsonDecodingException: $message';
}

/// Occurs while deserializing a decoded JSON object.
/// Indicates a structural or type mismatch between JSON and the expected model.
final class JsonDeserializationException extends JsonParseException {
  const JsonDeserializationException(this.decodedJson, this.reason)
    : super(
        'JSON deserialization failed. Reason: $reason\nDecoded JSON: $decodedJson',
      );
  final String reason;
  final JsonMap decodedJson;

  @override
  String toString() => '$JsonDeserializationException: $message';
}

/// Occurs when a valid JSON value is not a JSON object ([JsonMap]).
///
/// Expected a JSON object, but got a different JSON type instead.
final class JsonObjectExpectedException extends JsonParseException {
  const JsonObjectExpectedException(this.actualType)
    : super('Expected a JSON object ($JsonMap) but got $actualType.');

  final Type actualType;
}
