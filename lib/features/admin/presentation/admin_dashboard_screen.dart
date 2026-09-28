import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/text_styles.dart';

/// Admin Dashboard Screen for Flutter Web & Desktop.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console • CarRent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data',
            onPressed: () {},
          ),
          const SizedBox(width: AppSizes.p12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= AppSizes.tabletMaxWidth;

          return Row(
            children: [
              if (isWide) _buildSidebar(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.p24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Operasional',
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: AppSizes.p8),
                      Text(
                        'Status armada, booking aktif, dan pendapatan real-time.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p24),

                      // Stat Cards Grid
                      Wrap(
                        spacing: AppSizes.p16,
                        runSpacing: AppSizes.p16,
                        children: [
                          _buildStatCard(
                            title: 'Total Armada',
                            value: '24 Mobil',
                            icon: Icons.directions_car_rounded,
                            color: AppColors.info,
                            isDark: isDark,
                          ),
                          _buildStatCard(
                            title: 'Armada Tersedia',
                            value: '18 Mobil',
                            icon: Icons.check_circle_outline_rounded,
                            color: AppColors.success,
                            isDark: isDark,
                          ),
                          _buildStatCard(
                            title: 'Sewa Aktif',
                            value: '6 Mobil',
                            icon: Icons.key_rounded,
                            color: AppColors.warning,
                            isDark: isDark,
                          ),
                          _buildStatCard(
                            title: 'Pendapatan Bulan Ini',
                            value: 'Rp 42.500.000',
                            icon: Icons.account_balance_wallet_outlined,
                            color: AppColors.primaryLight,
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p32),

                      // Notice Card for Phase 9-11
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.p20),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.accent,
                                size: 28,
                              ),
                              const SizedBox(width: AppSizes.p16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Admin Dashboard Phase 1 Baseline',
                                      style: AppTextStyles.titleSmall,
                                    ),
                                    const SizedBox(height: AppSizes.p4),
                                    Text(
                                      'Manajemen armada lengkap (CRUD), audit log, manajemen booking, dan analitik interaktif akan diaktifkan pada Phase 9-11.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDark) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
        children: [
          _buildSidebarItem(Icons.dashboard_rounded, 'Dashboard', true),
          _buildSidebarItem(Icons.directions_car_rounded, 'Armada Mobil', false),
          _buildSidebarItem(Icons.receipt_long_rounded, 'Manajemen Booking', false),
          _buildSidebarItem(Icons.people_outline_rounded, 'Pengguna', false),
          _buildSidebarItem(Icons.local_offer_outlined, 'Promosi', false),
          _buildSidebarItem(Icons.history_rounded, 'Audit Logs', false),
          _buildSidebarItem(Icons.cloud_download_outlined, 'Data Importer', false),
          _buildSidebarItem(Icons.settings_outlined, 'Pengaturan', false),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, bool isSelected) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryLight : AppColors.textSecondaryLight,
        size: 20,
      ),
      title: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(
          color: isSelected ? AppColors.primaryLight : null,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onTap: () {},
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: AppSizes.radiusSm,
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p12),
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
