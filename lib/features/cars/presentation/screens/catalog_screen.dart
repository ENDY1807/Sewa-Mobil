import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/car_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../domain/repositories/car_repository.dart';
import '../providers/car_providers.dart';
import '../widgets/filter_bottom_sheet.dart';

/// Full-featured Catalog & Explore Screen with Search, Live Filters, and Sorting.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(carFilterParamsProvider).searchQuery;
    if (initialQuery != null) {
      _searchController.text = initialQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilter() async {
    final currentParams = ref.read(carFilterParamsProvider);
    final newParams = await FilterBottomSheet.show(context, currentParams);
    if (newParams != null) {
      ref.read(carFilterParamsProvider.notifier).state = newParams;
    }
  }

  void _clearSearch() {
    _searchController.clear();
    final current = ref.read(carFilterParamsProvider);
    ref.read(carFilterParamsProvider.notifier).state = current.copyWith(searchQuery: '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterParams = ref.watch(carFilterParamsProvider);
    final carsAsync = ref.watch(filteredCarsProvider);

    final hasActiveFilter = filterParams.brandId != null ||
        filterParams.categoryId != null ||
        filterParams.transmission != null ||
        filterParams.fuelType != null ||
        filterParams.minSeats != null ||
        (filterParams.minPrice != null && filterParams.minPrice! > 250000) ||
        (filterParams.maxPrice != null && filterParams.maxPrice! < 5000000);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Kendaraan'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Filter Kendaraan',
                onPressed: _openFilter,
              ),
              if (hasActiveFilter)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.p8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'Cari model atau merek...',
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                    onSubmitted: (query) {
                      final current = ref.read(carFilterParamsProvider);
                      ref.read(carFilterParamsProvider.notifier).state =
                          current.copyWith(searchQuery: query.trim());
                    },
                  ),
                ),
              ],
            ),
          ),

          // Active Filter Chips Indicator
          if (hasActiveFilter) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: 4),
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: [
                  InputChip(
                    label: const Text('Filter Aktif'),
                    avatar: const Icon(Icons.check, size: 14),
                    onDeleted: () {
                      ref.read(carFilterParamsProvider.notifier).state = const CarFilterParams();
                    },
                    deleteIconColor: AppColors.error,
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 16),

          // Car List Results
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.refresh(filteredCarsProvider);
              },
              child: carsAsync.when(
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.p20),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p16),
                  itemBuilder: (_, __) => const LoadingSkeleton(
                    height: 280,
                    borderRadius: AppSizes.radiusLg,
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.p24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Terjadi kesalahan: $err'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.refresh(filteredCarsProvider),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (cars) {
                  if (cars.isEmpty) {
                    return EmptyStateWidget(
                      title: AppStrings.emptyCarsTitle,
                      subtitle: AppStrings.emptyCarsSubtitle,
                      icon: Icons.search_off_rounded,
                      action: ElevatedButton(
                        onPressed: () {
                          _searchController.clear();
                          ref.read(carFilterParamsProvider.notifier).state = const CarFilterParams();
                        },
                        child: const Text('Reset Semua Filter'),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.p20),
                    itemCount: cars.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p16),
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return CarCard(
                        car: car,
                        onTap: () => context.push(AppRoutes.carDetailPath(car.id)),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
