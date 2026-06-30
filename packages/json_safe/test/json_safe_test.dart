import 'package:json_safe/json_safe.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

void main() {
  group('validate types', () {
    test('$JsonMap', () {
      final JsonMap json = {'id': 1};
      expect(json, isA<Map<String, JsonValue>>());
    });
    test('$JsonList', () {
      final JsonList json = [
        {'id': 1},
        {'id': 2},
      ];
      expect(json, isA<List<JsonValue>>());
    });
    test('$JsonValue', () {
      const JsonValue json = null;
      expect(json, isA<Object?>());
    });
  });

  test('jsonEncodePretty returns the JSON correctly', () {
    final JsonMap json = {
      'id': 0,
      'name': 'Steve',
      'image': null,
      'ownsMinecraft': true,
    };
    expect(jsonEncodePretty(json), '''
{
  "id": 0,
  "name": "Steve",
  "image": null,
  "ownsMinecraft": true
}''');
  });

  group('decodeJsonStringToMap', () {
    test('throws $JsonDecodingException when JSON is malformed', () {
      const malformedInputs = [
        '',
        '{',
        '}',
        '[}',
        '{,',
        '},',
        '{"id": 1,}',
        '{"id": }',
        '{"id":',
        '{"id": 1',
        '{"id" 1}',
        '{"id": 1,, "name": "test"}',
        '{"id": 1 "name": "test"}',
        '{"id": "test}',
        "{'id': 'test'}",
      ];

      for (final input in malformedInputs) {
        expect(
          () => decodeJsonStringToMap(input),
          throwsA(isA<JsonDecodingException>()),
        );
      }
    });

    test('throws $JsonObjectExpectedException when JSON is not a $JsonMap', () {
      const invalidInputs = [
        'null',
        '[]',
        '[1, 2, 3]',
        '"JSON"',
        '""',
        'true',
        'false',
        '0',
        '1',
        '-1',
        '3.14',
      ];

      for (final input in invalidInputs) {
        expect(
          () => decodeJsonStringToMap(input),
          throwsA(isA<JsonObjectExpectedException>()),
        );
      }
    });

    test('returns a valid $JsonMap when JSON is valid', () {
      final result = decodeJsonStringToMap('{}');
      expect(result, equals({}));
      expect(result, isA<JsonMap>());
    });
  });

  group('deserializeJsonMap', () {
    test(
      'throws $JsonDeserializationException when model is incompatible with input',
      () {
        final input = {'userId': '1'};

        expect(
          () => deserializeJsonMap(input, fromJson: _User.fromJson),
          throwsA(isA<JsonDeserializationException>()),
        );
      },
    );

    test('returns correctly when model is compatible with input', () {
      final input = {'email': 'email@example.com', 'userId': 1};

      expect(
        () => deserializeJsonMap(input, fromJson: _User.fromJson),
        returnsNormally,
      );
    });
  });

  test('deserializeJson returns model correctly', () {
    const input = '{"email": "contact@example.com", "userId": 2}';

    final result = deserializeJson(input, _User.fromJson);

    expect(result.email, 'contact@example.com');
    expect(result.userId, 2);
  });
}

@immutable
class _User {
  const _User({required this.email, required this.userId});

  factory _User.fromJson(JsonMap json) =>
      _User(email: json['email']! as String, userId: json['userId']! as int);

  final String email;
  final int userId;
}
