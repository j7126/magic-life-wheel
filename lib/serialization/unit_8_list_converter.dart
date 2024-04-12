import "dart:convert";
import "dart:typed_data";

import "package:json_annotation/json_annotation.dart";

class Uint8ListConverter implements JsonConverter<Uint8List?, String?> {
  const Uint8ListConverter();

  @override
  Uint8List? fromJson(String? json) {
    if (json == null) return null;

    return base64Decode(json);
  }

  @override
  String? toJson(Uint8List? data) {
    if (data == null) return null;

    return base64Encode(data);
  }
}
