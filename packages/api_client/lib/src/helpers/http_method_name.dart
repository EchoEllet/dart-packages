import 'package:http_method_enum/http_method_enum.dart';

extension HttpMethodName on HttpMethod {
  /// Returns the HTTP method name as a [String] that can be used
  /// with [http.MultipartRequest] or [http.Request] from `package:http`.
  ///
  /// This matches the HTTP method names with internal `package:http` code:
  /// https://github.com/dart-lang/http/blob/6656f15e88e68f6cafa2a7bbffa37fd6ac2dd33a/pkgs/http/lib/src/base_client.dart#L21-L47
  //
  /// We intentionally avoid using `method.name.toUpperCase()` because
  /// that would couple the [HttpMethod] enum names to `package:http` implementation.
  /// Renaming an enum value could then introduce a regression.
  String httpMethodName() => switch (this) {
    .get => 'GET',
    .head => 'HEAD',
    .post => 'POST',
    .put => 'PUT',
    .patch => 'PATCH',
    .delete => 'DELETE',
  };
}
