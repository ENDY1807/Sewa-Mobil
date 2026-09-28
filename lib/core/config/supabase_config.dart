import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import 'env_config.dart';

/// Supabase client configuration and initialization.
class SupabaseConfig {
  SupabaseConfig._();

  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      try {
        _client = Supabase.instance.client;
      } catch (e) {
        throw StateError(
          'Supabase has not been initialized. Ensure SupabaseConfig.initialize() is called.',
        );
      }
    }
    return _client!;
  }

  static bool get isInitialized {
    try {
      return Supabase.instance.client != null;
    } catch (_) {
      return false;
    }
  }

  static Future<void> initialize() async {
    final url = EnvConfig.supabaseUrl;
    final anonKey = EnvConfig.supabaseAnonKey;

    if (url.isEmpty || anonKey.isEmpty) {
      AppLogger.w('Supabase URL or Anon Key is empty. Supabase client will not be initialized.');
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _client = Supabase.instance.client;
      AppLogger.i('Supabase initialized successfully with endpoint: $url');
    } catch (e, st) {
      AppLogger.e('Failed to initialize Supabase', e, st);
    }
  }
}
