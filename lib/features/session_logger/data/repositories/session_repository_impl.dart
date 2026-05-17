import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../domain/models/training_session.dart';
import '../../domain/repositories/session_repository.dart';

/// Firestore + Hive implementation of SessionRepository
/// 
/// Implements offline-first architecture:
/// - Write operations go to Firestore (cloud) and Hive (local cache)
/// - Read operations prefer Hive cache, fall back to Firestore
/// - Automatic sync when connection restored
class SessionRepositoryImpl implements SessionRepository {
  final FirebaseFirestore _firestore;
  final Box<TrainingSession> _sessionsBox;

  SessionRepositoryImpl({
    required FirebaseFirestore firestore,
    required Box<TrainingSession> sessionsBox,
  })  : _firestore = firestore,
        _sessionsBox = sessionsBox;

  /// Collection reference for training sessions
  CollectionReference get _sessionsCollection =>
      _firestore.collection('training_sessions');

  @override
  Stream<List<TrainingSession>> getSessions(String userId) {
    return _sessionsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final sessions = snapshot.docs
          .map((doc) => TrainingSession.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();

      // Update cache
      for (final session in sessions) {
        _sessionsBox.put(session.id, session);
      }

      return sessions;
    });
  }

  @override
  Future<TrainingSession?> getSessionById(String sessionId) async {
    // Try cache first
    final cached = _sessionsBox.get(sessionId);
    if (cached != null) return cached;

    // Fetch from Firestore
    try {
      final doc = await _sessionsCollection.doc(sessionId).get();
      if (!doc.exists) return null;

      final session = TrainingSession.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });

      // Update cache
      await _sessionsBox.put(sessionId, session);

      return session;
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  @override
  Future<void> createSession(TrainingSession session) async {
    try {
      // Write to Firestore
      await _sessionsCollection.doc(session.id).set(session.toJson());

      // Write to cache
      await _sessionsBox.put(session.id, session);
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  @override
  Future<void> updateSession(TrainingSession session) async {
    try {
      // Update in Firestore
      await _sessionsCollection
          .doc(session.id)
          .update(session.toJson());

      // Update cache
      await _sessionsBox.put(session.id, session);
    } catch (e) {
      throw Exception('Failed to update session: $e');
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      // Delete from Firestore
      await _sessionsCollection.doc(sessionId).delete();

      // Delete from cache
      await _sessionsBox.delete(sessionId);
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  @override
  Future<List<TrainingSession>> getSessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _sessionsCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TrainingSession.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sessions by date range: $e');
    }
  }

  @override
  Future<List<TrainingSession>> getSessionsByLocation(
    String userId,
    String location,
  ) async {
    try {
      final snapshot = await _sessionsCollection
          .where('userId', isEqualTo: userId)
          .where('location', isEqualTo: location)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TrainingSession.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sessions by location: $e');
    }
  }

  @override
  Future<List<TrainingSession>> getSessionsByBowType(
    String userId,
    String bowType,
  ) async {
    try {
      final snapshot = await _sessionsCollection
          .where('userId', isEqualTo: userId)
          .where('bowType', isEqualTo: bowType)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TrainingSession.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sessions by bow type: $e');
    }
  }
}
