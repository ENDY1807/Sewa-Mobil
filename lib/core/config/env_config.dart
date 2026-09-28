import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

/// Environment variable configuration wrapper.
/// Reads values securely from the `.env` file.
class EnvConfig {
  EnvConfig._();

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
      AppLogger.i('Environment configuration loaded successfully.');
    } catch (e, st) {
      AppLogger.w('Could not load .env file, falling back to default/empty values.', e, st);
    }
  }

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ??
      dotenv.env['NEXT_PUBLIC_SUPABASE_URL'] ??
      '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      dotenv.env['NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY'] ??
      '';

  static String get appName => dotenv.env['APP_NAME'] ?? 'CarRent';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
