import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/car_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../providers/favorites_provider.dart';

/// Full-featured Favorites Screen displaying user's bookmarked cars.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navFavorites),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Perbarui',
            onPressed: () => ref.read(favoritesListProvider.notifier).refreshFavorites(),
          ),
          const SizedBox(width: AppSizes.p8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(favoritesListProvider.notifier).refreshFavorites(),
        child: favoritesAsync.when(
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p20),
            itemCount: 3,
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
                  Text('Gagal memuat favorit: $err'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.read(favoritesListProvider.notifier).refreshFavorites(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
          data: (cars) {
            if (cars.isEmpty) {
              return EmptyStateWidget(
                title: AppStrings.emptyFavoritesTitle,
                subtitle: AppStrings.emptyFavoritesSubtitle,
                icon: Icons.favorite_border_rounded,
                action: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.explore),
                  icon: const Icon(Icons.explore_rounded, size: 18),
                  label: const Text('Jelajahi Katalog Mobil'),
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
                  isFavorite: true,
                  onTap: () => context.push(AppRoutes.carDetailPath(car.id)),
                  onFavoriteTap: () async {
                    await ref.read(favoritesListProvider.notifier).toggleFavorite(car);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${car.model} dihapus dari favorit.'),
                          action: SnackBarAction(
                            label: 'Batal',
                            textColor: AppColors.accent,
                            onPressed: () {
                              ref.read(favoritesListProvider.notifier).toggleFavorite(car);
                            },
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
