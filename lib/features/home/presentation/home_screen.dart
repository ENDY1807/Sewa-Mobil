import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/env_config.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/car_card.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../cars/presentation/providers/car_providers.dart';

/// Modern, clean Home Screen for CarRent displaying live vehicle catalog from Supabase.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    final featuredCarsAsync = ref.watch(featuredCarsProvider);

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
            // Backend / Supabase Status Banner
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

            // Live Featured Cars from Riverpod
            featuredCarsAsync.when(
              loading: () => Column(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.p16),
                    child: LoadingSkeleton(
                      height: 240,
                      borderRadius: AppSizes.radiusLg,
                    ),
                  ),
                ),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(AppSizes.p24),
                child: Text('Gagal memuat katalog: $err'),
              ),
              data: (cars) => Column(
                children: cars.map((car) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.p16),
                    child: CarCard(
                      car: car,
                      onTap: () => context.push(AppRoutes.carDetailPath(car.id)),
                    ),
                  );
                }).toList(),
              ),
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
                      ? 'Katalog Mobil & Database aktif: ${EnvConfig.supabaseUrl}'
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
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: AppStrings.searchPlaceholder,
            ),
            onSubmitted: (query) {
              ref.read(carFilterParamsProvider.notifier).state =
                  CarFilterParams(searchQuery: query);
              context.push(AppRoutes.explore);
            },
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
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppSizes.radiusFull,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
            ),
          );
        },
      ),
    );
  }
}
