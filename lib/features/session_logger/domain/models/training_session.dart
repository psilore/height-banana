import 'package:freezed_annotation/freezed_annotation.dart';
import 'end.dart';
import 'target_face.dart';
import 'arrow.dart';

part 'training_session.freezed.dart';
part 'training_session.g.dart';

/// Represents a complete archery training session.
/// 
/// A session consists of multiple ends shot at a specific distance
/// with a particular bow and target configuration.
@freezed
class TrainingSession with _$TrainingSession {
  const factory TrainingSession({
    /// Unique identifier for this session
    required String id,
    
    /// User who owns this session
    required String userId,
    
    /// Date of the training session
    required DateTime date,
    
    /// Location where training took place
    required String location,
    
    /// Type of bow used (recurve, compound, longbow, etc.)
    required String bowType,
    
    /// Distance to target in meters
    required double distanceMeters,
    
    /// Target face configuration
    required TargetFace targetFace,
    
    /// List of ends in this session
    @Default([]) List<End> ends,
    
    /// Optional notes about the session
    String? notes,
  }) = _TrainingSession;

  const TrainingSession._();

  factory TrainingSession.fromJson(Map<String, dynamic> json) => 
      _$TrainingSessionFromJson(json);

  /// Calculate total score across all ends
  int get totalScore => ends.fold(0, (sum, end) => sum + end.totalScore);

  /// Calculate average score per arrow
  double get averageScore {
    final totalArrows = ends.fold(0, (sum, end) => sum + end.arrows.length);
    return totalArrows > 0 ? totalScore / totalArrows : 0.0;
  }

  /// Calculate total number of arrows shot
  int get totalArrows => ends.fold(0, (sum, end) => sum + end.arrows.length);

  /// Get all arrows from all ends
  List<Arrow> get allArrows => ends.expand((end) => end.arrows).toList();
}
