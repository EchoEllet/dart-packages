enum HttpMethod {
  get(supportsRequestBody: false),
  post(supportsRequestBody: true),
  put(supportsRequestBody: true),
  patch(supportsRequestBody: true),
  delete(supportsRequestBody: true);

  const HttpMethod({required this.supportsRequestBody});

  // The values respect: https://datatracker.ietf.org/doc/html/rfc7231
  final bool supportsRequestBody;

  // Hardcodes the name instead of using name.toUpperCase()
  // to prevent unintended breaking changes when renaming enums
  String get httpName => switch (this) {
    HttpMethod.get => 'GET',
    HttpMethod.post => 'POST',
    HttpMethod.put => 'PUT',
    HttpMethod.patch => 'PATCH',
    HttpMethod.delete => 'DELETE',
  };
}
