import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/config/env_config.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/price_text.dart';
import '../../../shared/widgets/status_badge.dart';

/// Modern, clean Home Screen for CarRent (Phase 1 Baseline).
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Semua',
    'SUV',
    'MPV',
    'Sedan',
    'Luxury',
    'Electric',
    'City Car',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSupabaseReady = SupabaseConfig.isInitialized;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppSizes.radiusMd,
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.p12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Rental Mobil Premium',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifikasi',
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: 'Admin Dashboard',
            onPressed: () => context.push(AppRoutes.adminDashboard),
          ),
          const SizedBox(width: AppSizes.p8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backend / Supabase Status Banner (Phase 1 verification)
            _buildConnectionBanner(isSupabaseReady, isDark),
            const SizedBox(height: AppSizes.p24),

            // Hero Greeting & Search Bar
            _buildHeroGreeting(isDark),
            const SizedBox(height: AppSizes.p20),

            // Search Bar & Filter Button
            _buildSearchSection(context, isDark),
            const SizedBox(height: AppSizes.p24),

            // Categories horizontal list
            _buildCategorySelector(isDark),
            const SizedBox(height: AppSizes.p28),

            // Featured Cars Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mobil Pilihan Populer',
                  style: AppTextStyles.titleMedium,
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.explore),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p12),

            // Preview Featured Cards (Phase 1 sample items)
            _buildFeaturedCard(
              context: context,
              brand: 'Toyota',
              model: 'Innova Zenix 2.0 V HV',
              type: 'MPV • Hybrid',
              price: 750000,
              seats: 7,
              transmission: 'Otomatis',
              isDark: isDark,
            ),
            const SizedBox(height: AppSizes.p16),
            _buildFeaturedCard(
              context: context,
              brand: 'Honda',
              model: 'CR-V 1.5 Turbo Prestige',
              type: 'SUV • Bensin',
              price: 850000,
              seats: 7,
              transmission: 'Otomatis',
              isDark: isDark,
            ),
            const SizedBox(height: AppSizes.p16),
            _buildFeaturedCard(
              context: context,
              brand: 'Hyundai',
              model: 'Ioniq 5 Signature Long Range',
              type: 'Electric • EV',
              price: 1200000,
              seats: 5,
              transmission: 'Otomatis',
              isDark: isDark,
            ),
            const SizedBox(height: AppSizes.p32),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.push(AppRoutes.explore);
              break;
            case 2:
              context.push(AppRoutes.bookingHistory);
              break;
            case 3:
              context.push(AppRoutes.favorites);
              break;
            case 4:
              context.push(AppRoutes.profile);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: AppStrings.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: AppStrings.navExplore,
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: AppStrings.navBookings,
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: AppStrings.navFavorites,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBanner(bool isReady, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p12),
      decoration: BoxDecoration(
        color: isReady
            ? (isDark ? const Color(0xFF064E3B) : AppColors.successContainer)
            : (isDark ? const Color(0xFF7F1D1D) : AppColors.errorContainer),
        borderRadius: AppSizes.radiusMd,
        border: Border.all(
          color: isReady ? AppColors.success : AppColors.error,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: isReady ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReady ? 'Supabase Backend Connected' : 'Supabase Not Connected',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isReady ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  isReady
                      ? 'Endpoint: ${EnvConfig.supabaseUrl}'
                      : 'Periksa file .env untuk kredensial Supabase.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroGreeting(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, Pengendara! 👋',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.p4),
        Text(
          'Temukan Mobil Nyaman\nUntuk Perjalanan Anda',
          style: AppTextStyles.titleLarge.copyWith(height: 1.25),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: AppStrings.searchPlaceholder,
            ),
            onSubmitted: (_) => context.push(AppRoutes.explore),
          ),
        ),
        const SizedBox(width: AppSizes.p12),
        InkWell(
          onTap: () => context.push(AppRoutes.explore),
          borderRadius: AppSizes.radiusMd,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppSizes.radiusMd,
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return ChoiceChip(
            label: Text(_categories[index]),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedCategoryIndex = index);
              }
            },
            selectedColor: AppColors.primary,
            labelStyle: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppSizes.radiusFull,
              side: BorderSide(
                color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard({
    required BuildContext context,
    required String brand,
    required String model,
    required String type,
    required num price,
    required int seats,
    required String transmission,
    required bool isDark,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header: Brand & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.accent,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      model,
                      style: AppTextStyles.titleSmall,
                    ),
                  ],
                ),
                StatusBadge.available(),
              ],
            ),
            const SizedBox(height: AppSizes.p12),

            // Car Visual Area
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                borderRadius: AppSizes.radiusMd,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.directions_car_filled_rounded,
                      size: 72,
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: AppSizes.radiusSm,
                      ),
                      child: Text(
                        type,
                        style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Specs Row
            Row(
              children: [
                _buildSpecIcon(Icons.airline_seat_recline_normal_rounded, '$seats Kursi', isDark),
                const SizedBox(width: AppSizes.p16),
                _buildSpecIcon(Icons.sync_alt_rounded, transmission, isDark),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.favorite_border_rounded, size: 20),
                  onPressed: () {},
                  tooltip: 'Favorit',
                ),
              ],
            ),
            const Divider(height: AppSizes.p24),

            // Bottom Action: Price and Rent Now Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PriceText(
                  amount: price,
                  isDark: isDark,
                ),
                ElevatedButton(
                  onPressed: () => context.push(AppRoutes.explore),
                  child: const Text(AppStrings.rentNow),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecIcon(IconData icon, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        ),
        const SizedBox(width: AppSizes.p4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
