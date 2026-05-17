import '../models/training_session.dart';

/// Repository interface for training session data operations.
/// 
/// Implementations handle Firestore + Hive offline sync for session data.
abstract class SessionRepository {
  /// Get all sessions for a specific user
  Stream<List<TrainingSession>> getSessions(String userId);

  /// Get a single session by ID
  Future<TrainingSession?> getSessionById(String sessionId);

  /// Create a new training session
  Future<void> createSession(TrainingSession session);

  /// Update an existing session
  Future<void> updateSession(TrainingSession session);

  /// Delete a session
  Future<void> deleteSession(String sessionId);

  /// Query sessions by date range
  Future<List<TrainingSession>> getSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Query sessions by location
  Future<List<TrainingSession>> getSessionsByLocation(
    String userId,
    String location,
  );

  /// Query sessions by bow type
  Future<List<TrainingSession>> getSessionsByBowType(
    String userId,
    String bowType,
  );
}
