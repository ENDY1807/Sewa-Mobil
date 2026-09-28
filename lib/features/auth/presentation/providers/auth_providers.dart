import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/error_handler.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

/// Provider for the AuthRepository singleton.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = SupabaseConfig.client;
  return AuthRepositoryImpl(supabase);
});

/// Stream provider for real-time authentication session changes.
final authStateStreamProvider = StreamProvider<UserProfile?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Current authenticated user profile provider.
final currentUserProfileProvider =
    AsyncNotifierProvider<CurrentUserProfileNotifier, UserProfile?>(
  CurrentUserProfileNotifier.new,
);

class CurrentUserProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    return repository.getCurrentUserProfile();
  }

  Future<void> refreshProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return repository.getCurrentUserProfile();
    });
  }

  void setProfile(UserProfile? profile) {
    state = AsyncValue.data(profile);
  }
}

/// State notifier for auth screen operations (login, register, logout).
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository, ref);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.login(email: email, password: password);
      _ref.read(currentUserProfileProvider.notifier).setProfile(profile);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(ErrorHandler.handleError(e, st).message, st);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      _ref.read(currentUserProfileProvider.notifier).setProfile(profile);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(ErrorHandler.handleError(e, st).message, st);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      _ref.read(currentUserProfileProvider.notifier).setProfile(null);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(ErrorHandler.handleError(e, st).message, st);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      await _repository.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(ErrorHandler.handleError(e, st).message, st);
      return false;
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    state = const AsyncValue.loading();
    try {
      await _repository.resetPassword(newPassword);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(ErrorHandler.handleError(e, st).message, st);
      return false;
    }
  }
}
