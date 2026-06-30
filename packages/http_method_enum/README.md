## Motivation

Provides a single canonical `HttpMethod` enum type that can be shared across packages, e.g., between client and server code (API contracts).

Has the following methods:

```dart
enum HttpMethod { get, head, post, put, patch, delete }
```

## Is this reinventing the wheel?

[http_methods](https://pub.dev/packages/http_methods) provides a full list of registered HTTP methods and indicates whether each method is considered safe according to specifications.

This package is more minimal for typical API clients and providers, exposing only the most commonly used HTTP methods as an enum instead of a list.

This package does not provide full IANA method coverage.
