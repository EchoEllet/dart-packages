/// Provides a single canonical [HttpMethod] enum type that can be shared across packages.
/// Not full IANA method coverage (unlike [http_methods](https://pub.dev/packages/http_methods)).
library;

/// Provides a single canonical HTTP method enum type that can
/// be shared across packages, e.g., between client and server code (API contracts).
///
/// For API contracts and REST semantics, not full IANA method coverage.
enum HttpMethod {
  get(supportsRequestBody: false),
  head(supportsRequestBody: false),
  post(supportsRequestBody: true),
  put(supportsRequestBody: true),
  patch(supportsRequestBody: true),
  delete(supportsRequestBody: true);

  const HttpMethod({required this.supportsRequestBody});

  /// Whether the HTTP method supports a request body.
  /// Based on HTTP semantics (RFC 9110 / 7231).
  //
  /// The values respect: https://datatracker.ietf.org/doc/html/rfc7231
  final bool supportsRequestBody;

  /// HTTP method token (RFC 9110).
  //
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
