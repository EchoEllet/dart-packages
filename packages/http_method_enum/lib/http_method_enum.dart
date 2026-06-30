enum HttpMethod {
  get(supportsRequestBody: false),
  head(supportsRequestBody: false),
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
    .get => 'GET',
    .head => 'HEAD',
    .post => 'POST',
    .put => 'PUT',
    .patch => 'PATCH',
    .delete => 'DELETE',
  };
}
