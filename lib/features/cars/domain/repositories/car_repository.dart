import '../entities/car.dart';
import '../entities/car_brand.dart';
import '../entities/car_category.dart';

/// Filter parameters for car catalog queries.
class CarFilterParams {
  final String? searchQuery;
  final String? brandId;
  final String? categoryId;
  final String? locationId;
  final num? minPrice;
  final num? maxPrice;
  final String? transmission;
  final String? fuelType;
  final int? minSeats;
  final bool? featuredOnly;
  final String? sortBy; // 'price_asc', 'price_desc', 'newest', 'popular', 'rating'
  final int page;
  final int limit;

  const CarFilterParams({
    this.searchQuery,
    this.brandId,
    this.categoryId,
    this.locationId,
    this.minPrice,
    this.maxPrice,
    this.transmission,
    this.fuelType,
    this.minSeats,
    this.featuredOnly,
    this.sortBy = 'recommended',
    this.page = 1,
    this.limit = 20,
  });

  CarFilterParams copyWith({
    String? searchQuery,
    String? brandId,
    String? categoryId,
    String? locationId,
    num? minPrice,
    num? maxPrice,
    String? transmission,
    String? fuelType,
    int? minSeats,
    bool? featuredOnly,
    String? sortBy,
    int? page,
    int? limit,
  }) {
    return CarFilterParams(
      searchQuery: searchQuery ?? this.searchQuery,
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
      locationId: locationId ?? this.locationId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      minSeats: minSeats ?? this.minSeats,
      featuredOnly: featuredOnly ?? this.featuredOnly,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

/// Interface contract for Car Catalog, Brands, and Categories.
abstract class CarRepository {
  Future<List<CarBrand>> getBrands();
  Future<List<CarCategory>> getCategories();
  Future<List<Car>> getCars({CarFilterParams params = const CarFilterParams()});
  Future<List<Car>> getFeaturedCars({int limit = 6});
  Future<List<Car>> getPopularCars({int limit = 6});
  Future<Car> getCarById(String id);
}
