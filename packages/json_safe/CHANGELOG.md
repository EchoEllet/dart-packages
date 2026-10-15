## 0.0.3

- Updates `decodeJsonStringToMap` and `deserializeJsonMap` to preserve original stack traces when mapping exceptions to `JsonDecodingException` and `JsonDeserializationException`.

## 0.0.2

- **Breaking Change**: `JsonObjectExpectedException` and `JsonDeserializationException` now require a non-null `String` source (named arguments).
  - This only impacts consumers who create these exceptions manually.

## 0.0.1

- Initial release.
