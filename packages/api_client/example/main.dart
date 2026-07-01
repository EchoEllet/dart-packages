// ignore_for_file: avoid_print

import 'package:api_client/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:json_safe/json_safe.dart';

void main() async {
  final httpClient = http.Client();

  try {
    // Use http package implementation
    final HttpApiClient client = HttpApiClientDart(httpClient);

    final result = await client.request(
      Uri.https('example.com'),
      method: HttpMethod.get,
    );

    print('Result 1: $result\n\n');

    final result2 = await client.requestJson(
      Uri.https('httpbin.org', 'post', {'name': 'test'}),
      method: HttpMethod.post,
      headers: {'Authorization': 'Bearer e_2323'},
      body: const RequestBody.json({'username': 'User', 'password': '123'}),
      deserializeSuccess: (response) =>
          _HttpBinPostResponse.fromJson(response.body),
      deserializeError: (response) => response.body,
    );

    print('Result 2: $result2');
  } finally {
    httpClient.close();
  }
}

// Dummy class
class _HttpBinPostResponse {
  _HttpBinPostResponse({
    required this.args,
    required this.headers,
    required this.data,
    required this.origin,
    required this.url,
  });

  factory _HttpBinPostResponse.fromJson(JsonMap json) {
    return _HttpBinPostResponse(
      args: Map<String, String>.from(json['args']! as JsonMap),
      headers: Map<String, String>.from(json['headers']! as JsonMap),
      data: json['data']! as String,
      origin: json['origin']! as String,
      url: json['url']! as String,
    );
  }

  final Map<String, String> args;
  final Map<String, String> headers;
  final String data;
  final String origin;
  final String url;

  JsonMap toJson() {
    return {
      'args': args,
      'headers': headers,
      'origin': origin,
      'url': url,
      'data': data,
    };
  }

  @override
  String toString() => jsonEncodePretty(toJson());
}
