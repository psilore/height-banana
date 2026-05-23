import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../domain/models/training_session.dart';
import '../../domain/repositories/session_repository.dart';
import '../../data/repositories/session_repository_impl.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Provider for SessionRepository implementation
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    sessionsBox: Hive.box<TrainingSession>('sessions_box'),
  );
});

/// Provider for sessions stream for current user
///
/// Automatically filters by authenticated user ID
final sessionsStreamProvider = StreamProvider<List<TrainingSession>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(sessionRepositoryProvider);
  return repository.getSessions(user.uid);
});

/// Provider for sessions list (sync version)
final sessionsListProvider = Provider<List<TrainingSession>>((ref) {
  final sessionsAsync = ref.watch(sessionsStreamProvider);
  return sessionsAsync.when(
    data: (sessions) => sessions,
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for creating a new session
final createSessionProvider =
    Provider<Future<void> Function(TrainingSession)>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return (session) => repository.createSession(session);
});

/// Provider for updating a session
final updateSessionProvider =
    Provider<Future<void> Function(TrainingSession)>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return (session) => repository.updateSession(session);
});

/// Provider for deleting a session
final deleteSessionProvider = Provider<Future<void> Function(String)>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return (sessionId) => repository.deleteSession(sessionId);
});

/// Provider for getting a specific session by ID
final sessionByIdProvider =
    FutureProvider.family<TrainingSession?, String>((ref, sessionId) async {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.getSessionById(sessionId);
});
