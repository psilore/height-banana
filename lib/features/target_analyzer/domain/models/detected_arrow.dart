import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:height_banana/core/utils/json_converters.dart';

part 'detected_arrow.freezed.dart';
part 'detected_arrow.g.dart';

/// Represents an arrow detected by computer vision during image analysis.
/// This is a temporary model used during the detection → confirmation flow.
/// Once confirmed, DetectedArrow instances are converted to domain Arrow models.
@freezed
class DetectedArrow with _$DetectedArrow {
  const factory DetectedArrow({
    /// Unique identifier for this detected arrow
    required String id,

    /// Position relative to target center in centimeters (x, y)
    /// (0, 0) is the target center
    @OffsetConverter()
    required Offset position,

    /// Detection confidence score (0.0 to 1.0)
    required double confidence,

    /// Calculated score value (X, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, M)
    required String score,
  }) = _DetectedArrow;

  factory DetectedArrow.fromJson(Map<String, dynamic> json) =>
      _$DetectedArrowFromJson(json);
}
