@experimental
@visibleForTesting
library;

import 'package:api_client/src/http_response.dart';
import 'package:json_safe/json_safe.dart';
import 'package:meta/meta.dart';

@visibleForTesting
JsonHttpResponse dummyJsonHttpResponse({
  JsonMap? body,
  int? statusCode,
  Map<String, String>? headers,
  String? reasonPhrase,
  int? contentLength,
}) => HttpResponse(
  body: body ?? {},
  statusCode: statusCode ?? 200,
  headers: headers ?? {},
  reasonPhrase: reasonPhrase ?? 'OK',
  contentLength: contentLength,
);

@visibleForTesting
HttpResponse<T> dummyHttpResponse<T>({
  required T body,
  int? statusCode,
  Map<String, String>? headers,
  String? reasonPhrase,
  int? contentLength,
}) => HttpResponse(
  body: body,
  statusCode: statusCode ?? 200,
  headers: headers ?? {},
  reasonPhrase: reasonPhrase ?? 'OK',
  contentLength: contentLength,
);
