import 'package:json_safe/json_safe.dart';
import 'package:meta/meta.dart';

typedef JsonHttpResponse = HttpResponse<JsonMap>;
typedef StringHttpResponse = HttpResponse<String>;

@immutable
class HttpResponse<T> {
  const HttpResponse({
    required this.body,
    required this.statusCode,
    required this.headers,
    required this.reasonPhrase,
    required this.contentLength,
  });

  final T body;
  final int statusCode;
  final Map<String, String> headers;
  final String? reasonPhrase;
  final int? contentLength;

  @override
  String toString() =>
      'HttpResponse<$T>(statusCode: $statusCode, body: $body, headers: $headers, reasonPhrase: $reasonPhrase, contentLength: $contentLength)';
}
