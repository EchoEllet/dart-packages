import 'package:api_client/src/http_response.dart';

/// HTTP response result split by status code (2xx vs non-2xx).
sealed class HttpStatusResult<S, E> {
  const HttpStatusResult();

  HttpStatusSuccess<S, E>? get success => switch (this) {
    final HttpStatusSuccess<S, E> value => value,
    _ => null,
  };

  HttpStatusError<S, E>? get error => switch (this) {
    final HttpStatusError<S, E> value => value,
    _ => null,
  };
}

/// 2xx HTTP response.
final class HttpStatusSuccess<S, E> extends HttpStatusResult<S, E> {
  const HttpStatusSuccess(this.response);

  /// Successful response body.
  final HttpResponse<S> response;

  @override
  String toString() => 'HttpStatusSuccess<$S>(responses: $response)';
}

/// Non-2xx HTTP response.
final class HttpStatusError<S, E> extends HttpStatusResult<S, E> {
  const HttpStatusError(this.response);

  /// Error response body.
  final HttpResponse<E> response;

  @override
  String toString() => 'HttpStatusError<$E>(responses: $response)';
}
