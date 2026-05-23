import '../../../session_logger/domain/models/target_face.dart';

/// Service for calculating arrow scores from coordinates
///
/// Maps arrow impact coordinates to score values based on
/// target face configuration and archery scoring rules.
class ScoreCalculationService {
  /// Calculate score from arrow coordinates
  ///
  /// [x] and [y] are coordinates in centimeters from target center
  /// [targetFace] defines the scoring zones
  ///
  /// Archery rule: If arrow touches a line, higher score is awarded
  String calculateScore(
    double x,
    double y,
    TargetFace targetFace,
  ) {
    // Use the target face's built-in calculation
    return targetFace.calculateScore(x, y);
  }

  /// Calculate score with line-touching detection
  ///
  /// Applies the archery rule: arrow touching a line between zones
  /// receives the higher score value.
  ///
  /// [touchMarginCm] is the margin in cm to consider "touching" (default 0.5cm)
  String calculateScoreWithLineDetection(
    double x,
    double y,
    TargetFace targetFace, {
    double touchMarginCm = 0.5,
  }) {
    final distance = (x * x + y * y);

    // Get scoring zones sorted by radius
    final sortedZones = targetFace.scoringZones.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Check each zone boundary
    for (int i = 0; i < sortedZones.length; i++) {
      final zone = sortedZones[i];
      final radiusSquared = zone.key * zone.key;

      // Check if arrow is within this zone
      if (distance <= radiusSquared) {
        // Check if arrow is touching the inner boundary (higher score)
        if (i > 0) {
          final innerZone = sortedZones[i - 1];
          final innerRadiusSquared = innerZone.key * innerZone.key;
          final touchDistance = (zone.key - touchMarginCm);
          final touchDistanceSquared = touchDistance * touchDistance;

          // If touching inner line, award inner (higher) score
          if (distance >= touchDistanceSquared &&
              distance <= innerRadiusSquared) {
            return innerZone.value; // Higher score
          }
        }

        return zone.value;
      }
    }

    return 'M'; // Miss - outside all zones
  }

  /// Batch calculate scores for multiple arrows
  List<String> calculateScoresForArrows(
    List<Map<String, double>> arrowCoordinates,
    TargetFace targetFace,
  ) {
    return arrowCoordinates.map((coords) {
      return calculateScore(
        coords['x']!,
        coords['y']!,
        targetFace,
      );
    }).toList();
  }

  /// Calculate numeric score from string value
  ///
  /// Converts score values to numbers for totaling
  int scoreToNumeric(String scoreValue) {
    switch (scoreValue.toUpperCase()) {
      case 'X':
        return 10; // Inner 10
      case 'M':
        return 0; // Miss
      default:
        return int.tryParse(scoreValue) ?? 0;
    }
  }

  /// Calculate total score for an end
  int calculateEndTotal(List<String> scores) {
    return scores.fold(0, (sum, score) => sum + scoreToNumeric(score));
  }

  /// Calculate average score for an end
  double calculateEndAverage(List<String> scores) {
    if (scores.isEmpty) return 0.0;
    final total = calculateEndTotal(scores);
    return total / scores.length;
  }

  /// Determine if score is on line between zones (for highlight/review)
  bool isScoreOnLine(
    double x,
    double y,
    TargetFace targetFace, {
    double touchMarginCm = 0.5,
  }) {
    final distance = (x * x + y * y);

    final sortedZones = targetFace.scoringZones.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final zone in sortedZones) {
      final innerRadius = zone.key - touchMarginCm;
      final innerRadiusSquared = innerRadius * innerRadius;
      final outerRadius = zone.key + touchMarginCm;
      final outerRadiusSquared = outerRadius * outerRadius;

      // Check if arrow is near this zone boundary
      if (distance >= innerRadiusSquared && distance <= outerRadiusSquared) {
        return true;
      }
    }

    return false;
  }

  /// Get score color for UI display
  ///
  /// Returns appropriate color based on score value
  String getScoreColor(String scoreValue) {
    switch (scoreValue.toUpperCase()) {
      case 'X':
      case '10':
        return '#FFD700'; // Gold
      case '9':
      case '8':
        return '#4CAF50'; // Green
      case '7':
      case '6':
        return '#2196F3'; // Blue
      case '5':
      case '4':
        return '#FF9800'; // Orange
      case '3':
      case '2':
      case '1':
        return '#F44336'; // Red
      case 'M':
        return '#9E9E9E'; // Gray
      default:
        return '#000000'; // Black
    }
  }

  /// Validate score value
  bool isValidScore(String scoreValue) {
    final validScores = [
      'X',
      '10',
      '9',
      '8',
      '7',
      '6',
      '5',
      '4',
      '3',
      '2',
      '1',
      'M',
    ];
    return validScores.contains(scoreValue.toUpperCase());
  }
}
