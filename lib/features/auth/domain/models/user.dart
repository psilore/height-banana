import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Represents an authenticated user in the system.
///
/// This model stores user authentication data from Firebase Auth
/// and is used throughout the app to identify the current user.
@freezed
class User with _$User {
  const factory User({
    /// Unique identifier from Firebase Auth
    required String uid,

    /// User's email address
    required String email,

    /// Display name (from Google profile)
    String? displayName,

    /// Profile photo URL (from Google profile)
    String? photoUrl,

    /// Timestamp when the user first signed in
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
