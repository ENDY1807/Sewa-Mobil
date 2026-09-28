import 'car_brand.dart';
import 'car_category.dart';
import 'car_feature.dart';
import 'car_image.dart';

/// Pure domain entity representing a vehicle in the CarRent catalog.
class Car {
  final String id;
  final String brandId;
  final String categoryId;
  final String? locationId;
  final String model;
  final String? variant;
  final int year;
  final String? description;
  final String transmission;
  final String fuelType;
  final int seats;
  final int doors;
  final String? color;
  final String? engine;
  final String? power;
  final num dailyPrice;
  final num? weeklyPrice;
  final num? monthlyPrice;
  final num deposit;
  final String status; // 'available', 'rented', 'maintenance', 'inactive'
  final String availabilityStatus; // 'available', 'reserved', 'unavailable'
  final bool featured;
  final double rating;
  final int totalReviews;
  final bool isDemo;
  final String? sourceName;
  final String? sourceUrl;
  final String? sourceId;
  final String? license;
  final String? attribution;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined Relations
  final CarBrand? brand;
  final CarCategory? category;
  final List<CarImage> images;
  final List<CarFeature> features;

  const Car({
    required this.id,
    required this.brandId,
    required this.categoryId,
    this.locationId,
    required this.model,
    this.variant,
    required this.year,
    this.description,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    this.doors = 4,
    this.color,
    this.engine,
    this.power,
    required this.dailyPrice,
    this.weeklyPrice,
    this.monthlyPrice,
    this.deposit = 0,
    this.status = 'available',
    this.availabilityStatus = 'available',
    this.featured = false,
    this.rating = 5.0,
    this.totalReviews = 0,
    this.isDemo = true,
    this.sourceName,
    this.sourceUrl,
    this.sourceId,
    this.license,
    this.attribution,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    this.category,
    this.images = const [],
    this.features = const [],
  });

  String get fullTitle => '${brand?.name ?? ''} $model ${variant ?? ''}'.trim();

  bool get isAvailable =>
      status == 'available' && availabilityStatus == 'available';

  String? get primaryImageUrl {
    if (images.isNotEmpty) {
      return images.first.imageUrl;
    }
    return null;
  }
}
