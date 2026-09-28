import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navProfile)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryContainer,
              child: const Icon(
                Icons.person_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p16),
          Text(
            'Tamu CarRent',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            'Silakan masuk untuk mengelola pesanan Anda',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.p24),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.login),
            child: const Text('Masuk / Daftar'),
          ),
          const SizedBox(height: AppSizes.p24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text('Admin Dashboard'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.adminDashboard),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('Bantuan & Dukungan'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
