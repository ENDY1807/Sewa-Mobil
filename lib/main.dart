import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/env_config.dart';
import 'core/config/supabase_config.dart';
import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables from .env
  await EnvConfig.initialize();

  // Initialize Supabase client
  await SupabaseConfig.initialize();

  AppLogger.i('CarRent application booted successfully.');

  runApp(
    const ProviderScope(
      child: CarRentApp(),
    ),
  );
}

class CarRentApp extends StatelessWidget {
  const CarRentApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
