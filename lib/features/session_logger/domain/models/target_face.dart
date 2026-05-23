import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:height_banana/core/utils/json_converters.dart';

part 'target_face.freezed.dart';
part 'target_face.g.dart';

/// Types of archery target faces
enum TargetType {
  /// FITA/WA 10-ring target (Olympic standard)
  fita,
  
  /// Field archery target
  field,
  
  /// 3D animal target
  threeD,
}

/// Represents the configuration of an archery target face.
/// 
/// Defines the scoring zones and their radii for calculating scores
/// from arrow coordinates.
@freezed
class TargetFace with _$TargetFace {
  const factory TargetFace({
    /// Type of target face
    required TargetType type,
    
    /// Physical diameter in centimeters
    required double diameterCm,
    
    /// Scoring ring definitions (radius in cm → score value)
    /// Example: {4.0: 'X', 6.0: '10', 11.0: '9', ...}
    @DoubleStringMapConverter()
    required Map<double, String> scoringZones,
  }) = _TargetFace;

  const TargetFace._();

  factory TargetFace.fromJson(Map<String, dynamic> json) => 
      _$TargetFaceFromJson(json);

  /// Standard FITA/WA 122cm 10-ring target
  factory TargetFace.fita122() {
    return const TargetFace(
      type: TargetType.fita,
      diameterCm: 122,
      scoringZones: {
        6.1: 'X',   // Inner 10 (gold center)
        12.2: '10', // 10 ring
        18.3: '9',  // 9 ring
        24.4: '8',  // 8 ring
        30.5: '7',  // 7 ring
        36.6: '6',  // 6 ring
        42.7: '5',  // 5 ring
        48.8: '4',  // 4 ring
        54.9: '3',  // 3 ring
        61.0: '2',  // 2 ring
        61.1: '1',  // 1 ring (anything within target)
      },
    );
  }

  /// Calculate score from coordinates (x, y in cm from center)
  String calculateScore(double x, double y) {
    final distance = (x * x + y * y);
    
    // Sort scoring zones by radius (ascending)
    final sortedZones = scoringZones.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    // Find the first zone that contains this distance
    for (final zone in sortedZones) {
      if (distance <= zone.key * zone.key) {
        return zone.value;
      }
    }
    
    // Outside all zones = miss
    return 'M';
  }
}
