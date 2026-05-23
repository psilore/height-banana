import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Converts a Flutter [Offset] to and from JSON.
class OffsetConverter implements JsonConverter<Offset, Map<String, dynamic>> {
  const OffsetConverter();

  @override
  Offset fromJson(Map<String, dynamic> json) {
    return Offset(
      (json['dx'] as num).toDouble(),
      (json['dy'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(Offset object) {
    return {
      'dx': object.dx,
      'dy': object.dy,
    };
  }
}

/// Converts a Map with double keys to and from JSON (since JSON requires string keys).
class DoubleStringMapConverter implements JsonConverter<Map<double, String>, Map<String, dynamic>> {
  const DoubleStringMapConverter();

  @override
  Map<double, String> fromJson(Map<String, dynamic> json) {
    return json.map((key, value) => MapEntry(double.parse(key), value as String));
  }

  @override
  Map<String, dynamic> toJson(Map<double, String> object) {
    return object.map((key, value) => MapEntry(key.toString(), value));
  }
}
