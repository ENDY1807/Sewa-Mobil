import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/repositories/car_repository_impl.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/car_brand.dart';
import '../../domain/entities/car_category.dart';
import '../../domain/repositories/car_repository.dart';

/// Provider for the CarRepository singleton.
final carRepositoryProvider = Provider<CarRepository>((ref) {
  final supabase = SupabaseConfig.client;
  return CarRepositoryImpl(supabase);
});

/// FutureProvider for the list of car brands.
final brandsListProvider = FutureProvider<List<CarBrand>>((ref) async {
  final repo = ref.watch(carRepositoryProvider);
  return repo.getBrands();
});

/// FutureProvider for the list of car categories.
final categoriesListProvider = FutureProvider<List<CarCategory>>((ref) async {
  final repo = ref.watch(carRepositoryProvider);
  return repo.getCategories();
});

/// FutureProvider for featured vehicles on homepage.
final featuredCarsProvider = FutureProvider<List<Car>>((ref) async {
  final repo = ref.watch(carRepositoryProvider);
  return repo.getFeaturedCars(limit: 6);
});

/// FutureProvider for popular vehicles.
final popularCarsProvider = FutureProvider<List<Car>>((ref) async {
  final repo = ref.watch(carRepositoryProvider);
  return repo.getPopularCars(limit: 6);
});

/// StateProvider holding the active search/filter state for catalog exploration.
final carFilterParamsProvider = StateProvider<CarFilterParams>((ref) {
  return const CarFilterParams();
});

/// FutureProvider returning cars based on active `carFilterParamsProvider`.
final filteredCarsProvider = FutureProvider<List<Car>>((ref) async {
  final repo = ref.watch(carRepositoryProvider);
  final params = ref.watch(carFilterParamsProvider);
  return repo.getCars(params: params);
});

/// FutureProvider.family returning single car detail by ID with joined relations.
final carDetailProvider = FutureProvider.family<Car, String>((ref, id) async {
  final repo = ref.watch(carRepositoryProvider);
  return repo.getCarById(id);
});
