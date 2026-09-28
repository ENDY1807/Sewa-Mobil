import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/car_brand.dart';
import '../../domain/entities/car_category.dart';
import '../../domain/repositories/car_repository.dart';
import '../models/car_brand_model.dart';
import '../models/car_category_model.dart';
import '../models/car_model.dart';

/// Concrete repository implementation fetching Car data from Supabase PostgreSQL.
class CarRepositoryImpl implements CarRepository {
  final supa.SupabaseClient _supabase;

  // In-memory caching for static metadata
  List<CarBrand>? _cachedBrands;
  List<CarCategory>? _cachedCategories;

  CarRepositoryImpl(this._supabase);

  static const String _carSelectQuery =
      '*, brands(*), categories(*), car_images(*), car_features(*)';

  @override
  Future<List<CarBrand>> getBrands() async {
    if (_cachedBrands != null && _cachedBrands!.isNotEmpty) {
      return _cachedBrands!;
    }

    try {
      final response = await _supabase
          .from('brands')
          .select()
          .order('name', ascending: true);

      final brands = (response as List)
          .map((json) => CarBrandModel.fromJson(json as Map<String, dynamic>))
          .toList();

      _cachedBrands = brands;
      return brands;
    } catch (e, st) {
      AppLogger.w('Failed to fetch brands from Supabase, returning fallback brands.', e, st);
      return _fallbackBrands;
    }
  }

  @override
  Future<List<CarCategory>> getCategories() async {
    if (_cachedCategories != null && _cachedCategories!.isNotEmpty) {
      return _cachedCategories!;
    }

    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('name', ascending: true);

      final categories = (response as List)
          .map((json) => CarCategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      _cachedCategories = categories;
      return categories;
    } catch (e, st) {
      AppLogger.w('Failed to fetch categories from Supabase, returning fallback categories.', e, st);
      return _fallbackCategories;
    }
  }

  @override
  Future<List<Car>> getCars({CarFilterParams params = const CarFilterParams()}) async {
    try {
      var query = _supabase.from('cars').select(_carSelectQuery);

      query = query.eq('status', 'available');

      if (params.brandId != null && params.brandId!.isNotEmpty) {
        query = query.eq('brand_id', params.brandId!);
      }
      if (params.categoryId != null && params.categoryId!.isNotEmpty) {
        query = query.eq('category_id', params.categoryId!);
      }
      if (params.locationId != null && params.locationId!.isNotEmpty) {
        query = query.eq('location_id', params.locationId!);
      }
      if (params.minPrice != null) {
        query = query.gte('daily_price', params.minPrice!);
      }
      if (params.maxPrice != null) {
        query = query.lte('daily_price', params.maxPrice!);
      }
      if (params.transmission != null && params.transmission!.isNotEmpty) {
        query = query.eq('transmission', params.transmission!);
      }
      if (params.fuelType != null && params.fuelType!.isNotEmpty) {
        query = query.eq('fuel_type', params.fuelType!);
      }
      if (params.minSeats != null) {
        query = query.gte('seats', params.minSeats!);
      }
      if (params.featuredOnly == true) {
        query = query.eq('featured', true);
      }
      if (params.searchQuery != null && params.searchQuery!.trim().isNotEmpty) {
        query = query.ilike('model', '%${params.searchQuery!.trim()}%');
      }

      // Sorting
      switch (params.sortBy) {
        case 'price_asc':
          query = query.order('daily_price', ascending: true);
          break;
        case 'price_desc':
          query = query.order('daily_price', ascending: false);
          break;
        case 'newest':
          query = query.order('year', ascending: false);
          break;
        case 'popular':
          query = query.order('total_reviews', ascending: false);
          break;
        case 'rating':
          query = query.order('rating', ascending: false);
          break;
        default:
          query = query.order('featured', ascending: false).order('created_at', ascending: false);
      }

      // Pagination
      final from = (params.page - 1) * params.limit;
      final to = from + params.limit - 1;
      query = query.range(from, to);

      final response = await query;

      final cars = (response as List)
          .map((json) => CarModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return cars.isNotEmpty ? cars : _fallbackCars;
    } catch (e, st) {
      AppLogger.w('Failed to query cars from Supabase, returning demo cars.', e, st);
      return _fallbackCars;
    }
  }

  @override
  Future<List<Car>> getFeaturedCars({int limit = 6}) async {
    try {
      final response = await _supabase
          .from('cars')
          .select(_carSelectQuery)
          .eq('status', 'available')
          .eq('featured', true)
          .limit(limit);

      final cars = (response as List)
          .map((json) => CarModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return cars.isNotEmpty ? cars : _fallbackCars.where((c) => c.featured).toList();
    } catch (e, st) {
      AppLogger.w('Failed to fetch featured cars from Supabase', e, st);
      return _fallbackCars.where((c) => c.featured).toList();
    }
  }

  @override
  Future<List<Car>> getPopularCars({int limit = 6}) async {
    try {
      final response = await _supabase
          .from('cars')
          .select(_carSelectQuery)
          .eq('status', 'available')
          .order('total_reviews', ascending: false)
          .limit(limit);

      final cars = (response as List)
          .map((json) => CarModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return cars.isNotEmpty ? cars : _fallbackCars;
    } catch (e, st) {
      AppLogger.w('Failed to fetch popular cars from Supabase', e, st);
      return _fallbackCars;
    }
  }

  @override
  Future<Car> getCarById(String id) async {
    try {
      final response = await _supabase
          .from('cars')
          .select(_carSelectQuery)
          .eq('id', id)
          .single();

      return CarModel.fromJson(response);
    } catch (e, st) {
      final fallback = _fallbackCars.firstWhere(
        (c) => c.id == id,
        orElse: () => _fallbackCars.first,
      );
      if (fallback.id == id) return fallback;
      throw ErrorHandler.handleError(e, st);
    }
  }

  // Built-in Fallbacks ensuring zero crashes during offline / seed pending
  static final List<CarBrand> _fallbackBrands = [
    CarBrand(id: 'b-1', name: 'Toyota', country: 'Japan', createdAt: DateTime.now()),
    CarBrand(id: 'b-2', name: 'Honda', country: 'Japan', createdAt: DateTime.now()),
    CarBrand(id: 'b-3', name: 'Hyundai', country: 'South Korea', createdAt: DateTime.now()),
    CarBrand(id: 'b-4', name: 'Mitsubishi', country: 'Japan', createdAt: DateTime.now()),
    CarBrand(id: 'b-5', name: 'BMW', country: 'Germany', createdAt: DateTime.now()),
  ];

  static final List<CarCategory> _fallbackCategories = [
    CarCategory(id: 'c-1', name: 'MPV', slug: 'mpv', createdAt: DateTime.now()),
    CarCategory(id: 'c-2', name: 'SUV', slug: 'suv', createdAt: DateTime.now()),
    CarCategory(id: 'c-3', name: 'Sedan', slug: 'sedan', createdAt: DateTime.now()),
    CarCategory(id: 'c-4', name: 'Electric', slug: 'electric', createdAt: DateTime.now()),
    CarCategory(id: 'c-5', name: 'Luxury', slug: 'luxury', createdAt: DateTime.now()),
  ];

  static final List<Car> _fallbackCars = [
    Car(
      id: 'car-zenix',
      brandId: 'b-1',
      categoryId: 'c-1',
      model: 'Innova Zenix 2.0 V HV',
      variant: 'Hybrid Modellista',
      year: 2024,
      transmission: 'Otomatis',
      fuelType: 'Hybrid',
      seats: 7,
      doors: 5,
      color: 'Platinum White Pearl',
      engine: '2.0L M20A-FXS Dual VVT-i',
      power: '186 PS',
      dailyPrice: 750000,
      weeklyPrice: 4700000,
      monthlyPrice: 18000000,
      deposit: 500000,
      featured: true,
      rating: 4.9,
      totalReviews: 48,
      isDemo: true,
      sourceName: 'CarRent Fleet Partner',
      license: 'Authorized Commercial Rental License',
      attribution: 'CarRent Fleet ID #001',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      brand: CarBrand(id: 'b-1', name: 'Toyota', country: 'Japan', createdAt: DateTime.now()),
      category: CarCategory(id: 'c-1', name: 'MPV', slug: 'mpv', createdAt: DateTime.now()),
    ),
    Car(
      id: 'car-crv',
      brandId: 'b-2',
      categoryId: 'c-2',
      model: 'CR-V 1.5 Turbo Prestige',
      variant: 'Honda SENSING',
      year: 2024,
      transmission: 'Otomatis',
      fuelType: 'Bensin',
      seats: 7,
      doors: 5,
      color: 'Crystal Black Pearl',
      engine: '1.5L VTEC Turbo DOHC',
      power: '190 PS',
      dailyPrice: 850000,
      weeklyPrice: 5300000,
      monthlyPrice: 20000000,
      deposit: 500000,
      featured: true,
      rating: 4.85,
      totalReviews: 32,
      isDemo: true,
      sourceName: 'CarRent Fleet Partner',
      license: 'Authorized Commercial Rental License',
      attribution: 'CarRent Fleet ID #002',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      brand: CarBrand(id: 'b-2', name: 'Honda', country: 'Japan', createdAt: DateTime.now()),
      category: CarCategory(id: 'c-2', name: 'SUV', slug: 'suv', createdAt: DateTime.now()),
    ),
    Car(
      id: 'car-ioniq5',
      brandId: 'b-3',
      categoryId: 'c-4',
      model: 'Ioniq 5 Signature Long Range',
      variant: 'EV 72.6 kWh',
      year: 2024,
      transmission: 'Otomatis',
      fuelType: 'Electric',
      seats: 5,
      doors: 5,
      color: 'Gravity Gold Matte',
      engine: 'Permanent Magnet Synchronous Motor',
      power: '217 PS / 350 Nm',
      dailyPrice: 1200000,
      weeklyPrice: 7500000,
      monthlyPrice: 28000000,
      deposit: 1000000,
      featured: true,
      rating: 4.95,
      totalReviews: 24,
      isDemo: true,
      sourceName: 'CarRent Fleet Partner',
      license: 'Authorized Commercial Rental License',
      attribution: 'CarRent Fleet ID #003',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      brand: CarBrand(id: 'b-3', name: 'Hyundai', country: 'South Korea', createdAt: DateTime.now()),
      category: CarCategory(id: 'c-4', name: 'Electric', slug: 'electric', createdAt: DateTime.now()),
    ),
  ];
}
