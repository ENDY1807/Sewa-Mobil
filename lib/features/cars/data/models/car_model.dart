import '../../domain/entities/car.dart';
import 'car_brand_model.dart';
import 'car_category_model.dart';
import 'car_feature_model.dart';
import 'car_image_model.dart';

class CarModel extends Car {
  const CarModel({
    required String id,
    required String brandId,
    required String categoryId,
    String? locationId,
    required String model,
    String? variant,
    required int year,
    String? description,
    required String transmission,
    required String fuelType,
    required int seats,
    int doors = 4,
    String? color,
    String? engine,
    String? power,
    required num dailyPrice,
    num? weeklyPrice,
    num? monthlyPrice,
    num deposit = 0,
    String status = 'available',
    String availabilityStatus = 'available',
    bool featured = false,
    double rating = 5.0,
    int totalReviews = 0,
    bool isDemo = true,
    String? sourceName,
    String? sourceUrl,
    String? sourceId,
    String? license,
    String? attribution,
    required DateTime createdAt,
    required DateTime updatedAt,
    CarBrandModel? brand,
    CarCategoryModel? category,
    List<CarImageModel> images = const [],
    List<CarFeatureModel> features = const [],
  }) : super(
          id: id,
          brandId: brandId,
          categoryId: categoryId,
          locationId: locationId,
          model: model,
          variant: variant,
          year: year,
          description: description,
          transmission: transmission,
          fuelType: fuelType,
          seats: seats,
          doors: doors,
          color: color,
          engine: engine,
          power: power,
          dailyPrice: dailyPrice,
          weeklyPrice: weeklyPrice,
          monthlyPrice: monthlyPrice,
          deposit: deposit,
          status: status,
          availabilityStatus: availabilityStatus,
          featured: featured,
          rating: rating,
          totalReviews: totalReviews,
          isDemo: isDemo,
          sourceName: sourceName,
          sourceUrl: sourceUrl,
          sourceId: sourceId,
          license: license,
          attribution: attribution,
          createdAt: createdAt,
          updatedAt: updatedAt,
          brand: brand,
          category: category,
          images: images,
          features: features,
        );

  factory CarModel.fromJson(Map<String, dynamic> json) {
    // Parse joined brand if present
    CarBrandModel? brandModel;
    if (json['brands'] != null && json['brands'] is Map<String, dynamic>) {
      brandModel = CarBrandModel.fromJson(json['brands'] as Map<String, dynamic>);
    }

    // Parse joined category if present
    CarCategoryModel? categoryModel;
    if (json['categories'] != null && json['categories'] is Map<String, dynamic>) {
      categoryModel = CarCategoryModel.fromJson(json['categories'] as Map<String, dynamic>);
    }

    // Parse joined images if present
    List<CarImageModel> imageModels = [];
    if (json['car_images'] != null && json['car_images'] is List) {
      imageModels = (json['car_images'] as List)
          .map((img) => CarImageModel.fromJson(img as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    // Parse joined features if present
    List<CarFeatureModel> featureModels = [];
    if (json['car_features'] != null && json['car_features'] is List) {
      featureModels = (json['car_features'] as List)
          .map((f) => CarFeatureModel.fromJson(f as Map<String, dynamic>))
          .toList();
    }

    return CarModel(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      categoryId: json['category_id'] as String,
      locationId: json['location_id'] as String?,
      model: json['model'] as String,
      variant: json['variant'] as String?,
      year: (json['year'] as num).toInt(),
      description: json['description'] as String?,
      transmission: json['transmission'] as String? ?? 'Otomatis',
      fuelType: json['fuel_type'] as String? ?? 'Bensin',
      seats: (json['seats'] as num?)?.toInt() ?? 5,
      doors: (json['doors'] as num?)?.toInt() ?? 4,
      color: json['color'] as String?,
      engine: json['engine'] as String?,
      power: json['power'] as String?,
      dailyPrice: json['daily_price'] as num? ?? 0,
      weeklyPrice: json['weekly_price'] as num?,
      monthlyPrice: json['monthly_price'] as num?,
      deposit: json['deposit'] as num? ?? 0,
      status: json['status'] as String? ?? 'available',
      availabilityStatus: json['availability_status'] as String? ?? 'available',
      featured: json['featured'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      isDemo: json['is_demo'] as bool? ?? true,
      sourceName: json['source_name'] as String?,
      sourceUrl: json['source_url'] as String?,
      sourceId: json['source_id'] as String?,
      license: json['license'] as String?,
      attribution: json['attribution'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      brand: brandModel,
      category: categoryModel,
      images: imageModels,
      features: featureModels,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand_id': brandId,
      'category_id': categoryId,
      'location_id': locationId,
      'model': model,
      'variant': variant,
      'year': year,
      'description': description,
      'transmission': transmission,
      'fuel_type': fuelType,
      'seats': seats,
      'doors': doors,
      'color': color,
      'engine': engine,
      'power': power,
      'daily_price': dailyPrice,
      'weekly_price': weeklyPrice,
      'monthly_price': monthlyPrice,
      'deposit': deposit,
      'status': status,
      'availability_status': availabilityStatus,
      'featured': featured,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_demo': isDemo,
      'source_name': sourceName,
      'source_url': sourceUrl,
      'source_id': sourceId,
      'license': license,
      'attribution': attribution,
    };
  }
}
