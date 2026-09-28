import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../cars/domain/entities/car.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/repositories/favorites_repository.dart';

/// Provider for the FavoritesRepository singleton.
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final supabase = SupabaseConfig.client;
  return FavoritesRepositoryImpl(supabase);
});

/// AsyncNotifier provider managing the user's active favorites list.
final favoritesListProvider =
    AsyncNotifierProvider<FavoritesListNotifier, List<Car>>(
  FavoritesListNotifier.new,
);

class FavoritesListNotifier extends AsyncNotifier<List<Car>> {
  @override
  Future<List<Car>> build() async {
    final repo = ref.watch(favoritesRepositoryProvider);
    return repo.getFavorites();
  }

  Future<void> refreshFavorites() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(favoritesRepositoryProvider);
      return repo.getFavorites();
    });
  }

  Future<bool> toggleFavorite(Car car) async {
    final repo = ref.read(favoritesRepositoryProvider);
    final isNowFav = await repo.toggleFavorite(car.id);

    final currentCars = state.value ?? [];
    if (isNowFav) {
      if (!currentCars.any((c) => c.id == car.id)) {
        state = AsyncValue.data([...currentCars, car]);
      }
    } else {
      state = AsyncValue.data(currentCars.where((c) => c.id != car.id).toList());
    }

    return isNowFav;
  }

  bool isCarFavorited(String carId) {
    return state.value?.any((c) => c.id == carId) ?? false;
  }
}
