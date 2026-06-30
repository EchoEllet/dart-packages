import 'dart:convert' as convert show JsonEncoder, jsonEncode;

import 'package:json_safe/src/types.dart';

String jsonEncodePretty(JsonMap map) =>
    convert.JsonEncoder.withIndent(' ' * 2).convert(map);

/// Type-safe wrapper over [convert.jsonEncode] that accepts a `Map` instead of `Object?`
String jsonEncode(JsonMap map) => convert.jsonEncode(map);
