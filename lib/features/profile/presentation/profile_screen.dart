import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/text_styles.dart';
import '../../auth/domain/entities/user_role.dart';
import '../../auth/presentation/providers/auth_providers.dart';

/// Production Profile Screen integrating Riverpod user state, role badges, and logout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Perbarui Profil',
            onPressed: () => ref.read(currentUserProfileProvider.notifier).refreshProfile(),
          ),
          const SizedBox(width: AppSizes.p8),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Gagal memuat profil: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(currentUserProfileProvider.notifier).refreshProfile(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return _buildGuestView(context, isDark);
          }
          return _buildAuthenticatedView(context, ref, profile, isDark);
        },
      ),
    );
  }

  Widget _buildGuestView(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_circle_outlined,
                size: 64,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.p20),
            Text(
              'Tamu CarRent',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              'Masuk atau daftar untuk mengakses riwayat booking, kendaraan favorit, dan status sewa Anda.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p24),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.login),
              child: const Text('Masuk / Daftar Akun'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(
    BuildContext context,
    WidgetRef ref,
    dynamic profile,
    bool isDark,
  ) {
    final role = profile.role as UserRole;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.p20),
      children: [
        // User Profile Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    profile.initials,
                    style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSizes.p16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName.isNotEmpty ? profile.fullName : 'Pengguna CarRent',
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: AppSizes.p4),
                      Text(
                        profile.email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      // Role Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: role.isAdmin
                              ? const Color(0xFFEF4444).withOpacity(0.12)
                              : (role.isStaff ? const Color(0xFFF59E0B).withOpacity(0.12) : AppColors.primaryContainer),
                          borderRadius: AppSizes.radiusFull,
                        ),
                        child: Text(
                          role.displayName.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: role.isAdmin
                                ? AppColors.error
                                : (role.isStaff ? AppColors.warning : AppColors.primary),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p20),

        // Admin Console Quick Link if staff or admin
        if (role.isStaffOrAdmin) ...[
          Card(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryLight),
              title: Text(
                'Admin Management Console',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Kelola armada, booking, dan analitik bisnis'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push(AppRoutes.adminDashboard),
            ),
          ),
          const SizedBox(height: AppSizes.p16),
        ],

        // Menu Sections
        Text(
          'Akun Saya',
          style: AppTextStyles.labelSmall.copyWith(
            color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.p8),

        ListTile(
          leading: const Icon(Icons.receipt_long_rounded),
          title: const Text('Riwayat Pesanan'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(AppRoutes.bookingHistory),
        ),
        ListTile(
          leading: const Icon(Icons.favorite_rounded),
          title: const Text('Kendaraan Favorit'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(AppRoutes.favorites),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_rounded),
          title: const Text('Notifikasi'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(AppRoutes.notifications),
        ),
        const Divider(height: AppSizes.p24),

        Text(
          'Pengaturan & Bantuan',
          style: AppTextStyles.labelSmall.copyWith(
            color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.p8),

        ListTile(
          leading: const Icon(Icons.help_outline_rounded),
          title: const Text('Pusat Bantuan & FAQ'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.policy_outlined),
          title: const Text('Ketentuan Layanan & Privasi'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {},
        ),
        const SizedBox(height: AppSizes.p20),

        // Logout Button
        OutlinedButton.icon(
          onPressed: () => _showLogoutConfirmation(context, ref),
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          label: const Text('Keluar dari Akun', style: TextStyle(color: AppColors.error)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error, width: 1.2),
          ),
        ),
        const SizedBox(height: AppSizes.p32),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun CarRent?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authControllerProvider.notifier).logout();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
