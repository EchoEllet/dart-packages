import 'dart:convert' as convert show jsonDecode;

import 'package:json_safe/src/decode_exceptions.dart';
import 'package:json_safe/src/types.dart';

/// Parses [input] into a [JsonMap].
///
/// ```dart
/// final decoded = decodeJsonStringToMap('{"id": 1}');
/// print(decoded['id']);
/// ```
///
/// Throws:
/// - [JsonDecodingException] if [input] is invalid JSON (e.g. `{'id': 1`).
/// - [JsonObjectExpectedException] if [input] is valid JSON but not a JSON map (e.g. `[]`).
JsonMap decodeJsonStringToMap(String input) {
  try {
    final decoded = convert.jsonDecode(input);
    if (decoded is! JsonMap) {
      throw JsonObjectExpectedException(decoded.runtimeType);
    }
    return decoded;
  } on FormatException catch (e) {
    throw JsonDecodingException(input, e.message);
  }
}

/// Deserializes a decoded JSON map into an instance of [T].
///
/// ```dart
/// class User(final String email, final int userId) {
///   factory fromJson(JsonMap json) => User(email: json['email']! as String, userId: json['userId']! as int);
/// }
///
/// final user = deserializeJsonMap(
///   {'email': 'email@example.com', 'userId': 1},
///   fromJson: User.fromJson,
/// );
/// ```
///
/// Throws [JsonDeserializationException] when there is a type mismatch between
/// JSON and the expected model.
///
/// For example:
///
/// ```dart
/// try {
///   deserializeJsonMap({'userId': '1'}, fromJson: User.fromJson);
/// } on JsonDeserializationException {
///   // Issues with above [JsonMap]:
///   // 1. email is missing
///   // 2. userId expected type is int, not a String
/// }
/// ```
///
/// Maps [TypeError] (that was thrown from [fromJson]) into [JsonDeserializationException].
///
/// Cast/null-assert errors inside fromJson are treated as expected
/// input validation errors.
T deserializeJsonMap<T>(
  JsonMap map, {
  required T Function(JsonMap json) fromJson,
}) {
  try {
    return fromJson(map);
    // fromJson() often uses 'as' and '!' operators, which can throw if the JSON
    // does not match the expected structure. This workaround catches those errors as failures.
    // ignore: avoid_catching_errors
  } on TypeError catch (e) {
    throw JsonDeserializationException(map, e.toString());
  }
}

/// Deserializes [input] into a model using [fromJson].
///
/// Throws a `JsonParseException` if the JSON:
///
/// - is malformed.
/// - is valid but its top-level value is not a JSON object (i.e., not a [JsonMap]).
/// - does not match the expected model.
T deserializeJson<T>(String input, T Function(JsonMap json) fromJson) {
  final decodedJson = decodeJsonStringToMap(input);
  final deserialized = deserializeJsonMap(decodedJson, fromJson: fromJson);

  return deserialized;
}
