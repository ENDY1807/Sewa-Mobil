import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/booking/presentation/booking_history_screen.dart';
import '../../features/cars/presentation/screens/car_detail_screen.dart';
import '../../features/cars/presentation/screens/catalog_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../shared/widgets/error_state.dart';
import 'route_names.dart';

/// Centralized application router with route definitions and error handling.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.explore,
        builder: (context, state) => const CatalogScreen(),
      ),
      GoRoute(
        path: '/cars/:id',
        builder: (context, state) {
          final carId = state.pathParameters['id'] ?? '';
          return CarDetailScreen(carId: carId);
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingHistory,
        builder: (context, state) => const BookingHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
      body: ErrorStateWidget(
        title: '404 - Halaman Tidak Ditemukan',
        message: 'Rute "${state.uri}" yang Anda cari tidak tersedia.',
        onRetry: () => context.go(AppRoutes.home),
      ),
    ),
  );
}
