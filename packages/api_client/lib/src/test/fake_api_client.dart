@experimental
@visibleForTesting
library;

import 'package:api_client/src/api_client.dart';
import 'package:api_client/src/http_status_result.dart';
import 'package:api_client/src/request_body.dart';
import 'package:api_client/src/test/http_response_dummy.dart';
import 'package:json_safe/json_safe.dart';
import 'package:meta/meta.dart';

/// Experimental API and may be removed or changed in future versions.
@experimental
@visibleForTesting
final class FakeApiClient implements ApiClient {
  final List<FakeHttpRequestCall> _requestCalls = [];
  final List<FakeHttpRequestJsonCall<Object, Object>> _requestJsonCalls = [];

  int get requestCallCount => _requestCalls.length;
  int get requestJsonCallCount => _requestJsonCalls.length;

  List<FakeHttpRequestCall> get requestCalls => .unmodifiable(_requestCalls);
  List<FakeHttpRequestJsonCall<Object, Object>> get requestJsonCalls =>
      .unmodifiable(_requestJsonCalls);

  Future<HttpStatusResult<String, String>> Function(FakeHttpRequestCall call)?
  whenRequest;
  Future<HttpStatusResult<S, E>> Function<S, E>(
    FakeHttpRequestJsonCall<S, E> call,
  )?
  whenRequestJson;

  Future<void> stubJsonSuccessAndRun<T>({
    required JsonMap json,
    required T expectedDecodedBody,
    required void Function(T result) assertion,
    required Future<void> Function() makeRequest,
  }) async {
    whenRequestJson = <S, E>(call) async {
      final result =
          call.deserializeSuccess(dummyJsonHttpResponse(body: json)) as T;

      assertion(result);

      return HttpStatusSuccess(dummyHttpResponse(body: result as S));
    };

    await makeRequest();
  }

  Future<void> stubJsonFailureAndRun<T>({
    required JsonMap json,
    required T expectedDecodedBody,
    required void Function(T result) assertion,
    required Future<void> Function() makeRequest,
  }) async {
    whenRequestJson = <S, E>(call) async {
      final result =
          call.deserializeError(dummyJsonHttpResponse(body: json)) as T;

      assertion(result);

      return HttpStatusError(dummyHttpResponse(body: result as E));
    };

    await makeRequest();
  }

  // Currently not needed, but archived just in case.
  // Future<void> stubJsonResultAndRun<T>({
  //   required JsonApiResult<T, Object> expectedResult,
  //   required Future<JsonApiResult<T, Object>> Function() makeRequest,
  //   required void Function(T result) assertion,
  // }) async {
  //   whenRequestJson = <S, E>(call) async {
  //     return expectedResult as JsonApiResult<S, E>;
  //   };

  //   final result = await makeRequest();

  //   assertion(result.valueOrThrow.body);
  // }

  @override
  Future<HttpStatusResult<String, String>> request(
    Uri url, {
    required HttpMethod method,
    Map<String, String>? headers,
    RequestBody? body,
  }) {
    final call = FakeHttpRequestCall(
      url: url,
      headers: headers,
      method: method,
      body: body,
    );
    _requestCalls.add(call);

    final whenRequest = this.whenRequest;
    if (whenRequest == null) {
      throw StateError(
        'No return value stubbed for $requestMethodName($url, method: $HttpMethod.${method.name})',
      );
    }
    final result = whenRequest.call(call);

    return result;
  }

  @override
  Future<HttpStatusResult<S, E>> requestJson<S, E>(
    Uri url, {
    required HttpMethod method,
    Map<String, String>? headers,
    RequestBody? body,
    required JsonResponseDeserializer<S> deserializeSuccess,
    required JsonResponseDeserializer<E> deserializeError,
  }) {
    final call = FakeHttpRequestJsonCall<S, E>(
      url: url,
      headers: headers,
      method: method,
      deserializeSuccess: deserializeSuccess,
      deserializeError: deserializeError,
      body: body,
    );
    _requestJsonCalls.add(call as FakeHttpRequestJsonCall<Object, Object>);

    final whenRequestJson = this.whenRequestJson;
    if (whenRequestJson == null) {
      throw StateError(
        'No return value stubbed for $requestJsonMethodName($url, method: $HttpMethod.${method.name})',
      );
    }

    final result = whenRequestJson.call<S, E>(call);

    return result;
  }

  static const requestJsonMethodName = 'requestJson';
  static const requestMethodName = 'request';

  void expectOnlyRequestCalls(int count) {
    if (requestCallCount != count) {
      throw StateError(
        'Expected $count $requestMethodName() calls but found $requestCallCount',
      );
    }
    if (requestJsonCallCount != 0) {
      throw StateError(
        'Expected 0 $requestJsonMethodName() calls but found $requestJsonCallCount',
      );
    }
  }

  void expectOnlyRequestJsonCalls(int count) {
    if (requestJsonCallCount != count) {
      throw StateError(
        'Expected $count $requestJsonMethodName() calls but found $requestJsonCallCount',
      );
    }
    if (requestCallCount != 0) {
      throw StateError(
        'Expected 0 $requestMethodName() calls but found $requestCallCount',
      );
    }
  }

  void expectSingleRequest({
    required bool isRequestJsonMethod,
    required HttpMethod method,
  }) {
    if (isRequestJsonMethod) {
      expectOnlyRequestJsonCalls(1);
    } else {
      expectOnlyRequestCalls(1);
    }

    final capturedMethod = requestJsonCalls.first.method;
    if (method != capturedMethod) {
      throw StateError(
        'Expected $HttpMethod.${method.name}, but got $capturedMethod.',
      );
    }
  }

  void reset() {
    _requestCalls.clear();
    _requestJsonCalls.clear();
    whenRequest = null;
    whenRequestJson = null;
  }
}

/// Shares properties between [FakeHttpRequestJsonCall] and [FakeHttpRequestCall].
@visibleForTesting
final class FakeHttpCall {
  FakeHttpCall({
    required this.url,
    required this.headers,
    required this.method,
    required this.body,
  });

  final Uri url;
  final Map<String, String>? headers;
  final HttpMethod method;

  final RequestBody? body;
}

@visibleForTesting
final class FakeHttpRequestJsonCall<S, E> {
  FakeHttpRequestJsonCall({
    required this.url,
    required this.headers,
    required this.method,
    required this.body,
    required this.deserializeSuccess,
    required this.deserializeError,
  });

  final Uri url;
  final Map<String, String>? headers;
  final HttpMethod method;

  final RequestBody? body;
  final JsonResponseDeserializer<S> deserializeSuccess;
  final JsonResponseDeserializer<E> deserializeError;
}

@visibleForTesting
final class FakeHttpRequestCall {
  FakeHttpRequestCall({
    required this.url,
    required this.headers,
    required this.method,
    required this.body,
  });

  final Uri url;
  final Map<String, String>? headers;
  final HttpMethod method;

  final RequestBody? body;
}
