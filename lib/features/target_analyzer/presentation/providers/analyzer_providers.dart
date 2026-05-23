import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/target_detection_service.dart';
import '../../data/datasources/arrow_detection_service.dart';
import '../../data/datasources/score_calculation_service.dart';

/// Provider for target detection service
final targetDetectionServiceProvider = Provider<TargetDetectionService>((ref) {
  return TargetDetectionService();
});

/// Provider for arrow detection service
final arrowDetectionServiceProvider = Provider<ArrowDetectionService>((ref) {
  return ArrowDetectionService(ref.read(targetDetectionServiceProvider));
});

/// Provider for score calculation service
final scoreCalculationServiceProvider = Provider<ScoreCalculationService>((ref) {
  return ScoreCalculationService();
});
