import 'package:flutter_test/flutter_test.dart';
import 'package:height_banana/features/target_analyzer/data/datasources/score_calculation_service.dart';
import 'package:height_banana/features/session_logger/domain/models/target_face.dart';

void main() {
  test('Score calculation', () {
    final service = ScoreCalculationService();
    final target = TargetFace.fita122();
    expect(service.calculateScore(0, 0, target), 'X');
  });
}
