import 'dart:math' as math;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'arrow.freezed.dart';
part 'arrow.g.dart';

/// Represents a single arrow shot at a target.
/// 
/// Each arrow has a score value and coordinates relative to the target center.
/// Coordinates are normalized where (0, 0) is the target center.
@freezed
class Arrow with _$Arrow {
  const factory Arrow({
    /// Unique identifier for this arrow
    required String id,
    
    /// Score value: 'X' (inner 10), '10', '9', '8', '7', '6', '5', '4', '3', '2', '1', 'M' (miss)
    required String score,
    
    /// X coordinate relative to target center (normalized)
    /// Negative = left of center, Positive = right of center
    required double x,
    
    /// Y coordinate relative to target center (normalized)
    /// Negative = above center, Positive = below center
    required double y,
    
    /// When this arrow was logged
    required DateTime timestamp,
  }) = _Arrow;

  const Arrow._();

  factory Arrow.fromJson(Map<String, dynamic> json) => _$ArrowFromJson(json);

  /// Convert score value to numeric points (X=10, M=0)
  int get numericScore {
    if (score == 'X') return 10;
    if (score == 'M') return 0;
    return int.tryParse(score) ?? 0;
  }

  /// Calculate distance from center point
  double get distanceFromCenter => math.sqrt(x * x + y * y);
}
