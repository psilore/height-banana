import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';

/// Provider for AuthRepository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    firebaseAuth: firebase_auth.FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
    firestore: FirebaseFirestore.instance,
  );
});

/// Provider for authentication state stream
///
/// Emits the current user when authenticated, null when signed out
final authStateProvider = StreamProvider<domain.User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Provider for current authenticated user
///
/// Returns null if not authenticated
final currentUserProvider = Provider<domain.User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
});

/// Provider for sign in action
final signInProvider = Provider<Future<domain.User> Function()>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return () => authRepository.signInWithGoogle();
});

/// Provider for sign out action
final signOutProvider = Provider<Future<void> Function()>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return () => authRepository.signOut();
});
