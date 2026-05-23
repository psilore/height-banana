import 'package:flutter_test/flutter_test.dart';
import 'package:height_banana/features/session_logger/domain/models/arrow.dart';

void main() {
  group('Arrow Tests', () {
    test('Distance calculation', () {
      final arrow = Arrow(
        id: 'test',
        score: '9',
        x: 3.0,
        y: 4.0,
        timestamp: DateTime.now(),
      );
      expect(arrow.distanceFromCenter, 5.0);
    });
  });
}
