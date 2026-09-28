import 'package:flutter_test/flutter_test.dart';
import 'package:sewamobil/features/cars/data/models/car_brand_model.dart';
import 'package:sewamobil/features/cars/data/models/car_category_model.dart';
import 'package:sewamobil/features/cars/data/models/car_model.dart';
import 'package:sewamobil/features/cars/domain/entities/car.dart';
import 'package:sewamobil/features/cars/domain/repositories/car_repository.dart';

void main() {
  group('Phase 3 Car Catalog Domain & Data Tests', () {
    test('CarBrandModel serializes and deserializes accurately', () {
      final json = {
        'id': 'b-1',
        'name': 'Toyota',
        'logo_url': 'https://example.com/toyota.png',
        'country': 'Japan',
        'description': 'Leading automaker',
        'website_url': 'https://toyota.astra.co.id',
        'created_at': '2026-09-29T05:00:00.000Z',
      };

      final brand = CarBrandModel.fromJson(json);

      expect(brand.id, equals('b-1'));
      expect(brand.name, equals('Toyota'));
      expect(brand.country, equals('Japan'));
      expect(brand.toJson()['name'], equals('Toyota'));
    });

    test('CarCategoryModel serializes and deserializes accurately', () {
      final json = {
        'id': 'c-1',
        'name': 'Electric',
        'slug': 'electric',
        'description': 'Eco-friendly vehicles',
        'icon_name': 'bolt',
        'created_at': '2026-09-29T05:00:00.000Z',
      };

      final category = CarCategoryModel.fromJson(json);

      expect(category.id, equals('c-1'));
      expect(category.slug, equals('electric'));
      expect(category.name, equals('Electric'));
    });

    test('CarModel parses joined relational objects seamlessly', () {
      final json = {
        'id': 'car-123',
        'brand_id': 'b-1',
        'category_id': 'c-1',
        'model': 'Innova Zenix',
        'variant': '2.0 V HV',
        'year': 2024,
        'transmission': 'Otomatis',
        'fuel_type': 'Hybrid',
        'seats': 7,
        'doors': 5,
        'daily_price': 750000,
        'deposit': 500000,
        'status': 'available',
        'availability_status': 'available',
        'featured': true,
        'rating': 4.95,
        'total_reviews': 48,
        'is_demo': true,
        'created_at': '2026-09-29T05:00:00.000Z',
        'updated_at': '2026-09-29T05:00:00.000Z',
        'brands': {
          'id': 'b-1',
          'name': 'Toyota',
          'country': 'Japan',
          'created_at': '2026-09-29T05:00:00.000Z',
        },
        'categories': {
          'id': 'c-1',
          'name': 'MPV',
          'slug': 'mpv',
          'created_at': '2026-09-29T05:00:00.000Z',
        },
        'car_images': [
          {
            'id': 'img-1',
            'car_id': 'car-123',
            'image_url': 'https://example.com/zenix.jpg',
            'sort_order': 0,
            'category': 'exterior',
            'created_at': '2026-09-29T05:00:00.000Z',
          }
        ],
      };

      final car = CarModel.fromJson(json);

      expect(car.id, equals('car-123'));
      expect(car.fullTitle, equals('Toyota Innova Zenix 2.0 V HV'));
      expect(car.brand?.name, equals('Toyota'));
      expect(car.category?.name, equals('MPV'));
      expect(car.isAvailable, isTrue);
      expect(car.primaryImageUrl, equals('https://example.com/zenix.jpg'));
    });

    test('CarFilterParams copyWith updates parameters immutably', () {
      const initial = CarFilterParams(minSeats: 5, page: 1);
      final updated = initial.copyWith(searchQuery: 'Zenix', page: 2);

      expect(updated.minSeats, equals(5));
      expect(updated.searchQuery, equals('Zenix'));
      expect(updated.page, equals(2));
      expect(initial.page, equals(1)); // immutability verified
    });
  });
}
