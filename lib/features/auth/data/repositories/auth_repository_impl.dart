import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_profile_model.dart';

/// Concrete implementation of [AuthRepository] using Supabase Auth & PostgreSQL.
class AuthRepositoryImpl implements AuthRepository {
  final supa.SupabaseClient _supabase;
  final _authStateController = StreamController<UserProfile?>.broadcast();

  AuthRepositoryImpl(this._supabase) {
    _initAuthListener();
  }

  void _initAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final supa.AuthChangeEvent event = data.event;
      final supa.Session? session = data.session;

      AppLogger.i('Supabase Auth state changed: $event');

      if (session != null && session.user != null) {
        final profile = await getCurrentUserProfile();
        _authStateController.add(profile);
      } else {
        _authStateController.add(null);
      }
    });
  }

  @override
  Stream<UserProfile?> get authStateChanges => _authStateController.stream;

  @override
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  @override
  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<UserProfile> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      AppLogger.i('Registering user with email: $email');

      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          if (phone != null) 'phone': phone.trim(),
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Registrasi gagal. Pengguna tidak dapat dibuat.');
      }

      // Allow trigger a moment, then fetch profile
      await Future.delayed(const Duration(milliseconds: 500));
      final profile = await getCurrentUserProfile();

      if (profile != null) {
        return profile;
      }

      // Fallback if trigger was delayed
      return UserProfile(
        id: user.id,
        email: email,
        fullName: fullName,
        phone: phone,
        role: UserRole.user,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e, st) {
      throw ErrorHandler.handleError(e, st);
    }
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.i('Logging in user: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Login gagal. Periksa email dan kata sandi Anda.');
      }

      final profile = await getCurrentUserProfile();
      if (profile != null) {
        return profile;
      }

      // Fallback minimal profile
      return UserProfile(
        id: user.id,
        email: user.email ?? email,
        fullName: user.userMetadata?['full_name'] ?? '',
        phone: user.userMetadata?['phone'],
        role: UserRole.user,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e, st) {
      throw ErrorHandler.handleError(e, st);
    }
  }

  @override
  Future<void> logout() async {
    try {
      AppLogger.i('Logging out user');
      await _supabase.auth.signOut();
    } catch (e, st) {
      throw ErrorHandler.handleError(e, st);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.i('Sending password reset email to: $email');
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'carrent://reset-password',
      );
    } catch (e, st) {
      throw ErrorHandler.handleError(e, st);
    }
  }

  @override
  Future<void> resetPassword(String newPassword) async {
    try {
      AppLogger.i('Resetting user password');
      await _supabase.auth.updateUser(
        supa.UserAttributes(password: newPassword),
      );
    } catch (e, st) {
      throw ErrorHandler.handleError(e, st);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null || user.email == null) {
        throw const UnauthorizedException();
      }

      // Verify current password first
      await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      // Apply new password
      await resetPassword(newPassword);
    } catch (e, st) {
      throw ErrorHandler.handleError(e, st);
    }
  }

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        AppLogger.w('Profile not yet created in public.profiles for user: ${user.id}');
        return UserProfile(
          id: user.id,
          email: user.email ?? '',
          fullName: user.userMetadata?['full_name'] ?? '',
          phone: user.userMetadata?['phone'],
          role: UserRole.user,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      return UserProfileModel.fromJson(response);
    } catch (e, st) {
      AppLogger.e('Failed to fetch user profile', e, st);
      return null;
    }
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw const UnauthorizedException();

    try {
      final updateData = <String, dynamic>{
        'full_name': fullName.trim(),
        'updated_at': DateTime.now().toIso8601String(),
        if (phone != null) 'phone': phone.trim(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      return UserProfileModel.fromJson(response);
    } catch (e, st) {
      throw ErrorHandler.handleError(e, st);
    }
  }
}
