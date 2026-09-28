import '../entities/user_profile.dart';

/// Contract for Authentication and Profile Management.
abstract class AuthRepository {
  /// Stream to listen to real-time authentication session changes.
  Stream<UserProfile?> get authStateChanges;

  /// Register a new user with Supabase Auth and initialize public profile.
  Future<UserProfile> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  /// Log in with email and password.
  Future<UserProfile> login({
    required String email,
    required String password,
  });

  /// Sign out the current user session.
  Future<void> logout();

  /// Send password reset instructions to user email.
  Future<void> sendPasswordResetEmail(String email);

  /// Complete password reset with new password.
  Future<void> resetPassword(String newPassword);

  /// Change password while authenticated.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Fetch the current user's profile from `profiles` table.
  Future<UserProfile?> getCurrentUserProfile();

  /// Update the current user's profile details.
  Future<UserProfile> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  });

  /// Check whether the user is currently authenticated.
  bool get isAuthenticated;

  /// Get current user ID if logged in.
  String? get currentUserId;
}
