import '../models/user.dart';

/// Repository interface for user authentication operations.
/// 
/// Implementations handle Firebase Authentication and user profile storage.
abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;

  /// Get the currently authenticated user
  User? get currentUser;

  /// Sign in with Google
  Future<User> signInWithGoogle();

  /// Sign out the current user
  Future<void> signOut();

  /// Get user profile from Firestore
  Future<User?> getUserProfile(String uid);

  /// Create or update user profile in Firestore
  Future<void> saveUserProfile(User user);
}
