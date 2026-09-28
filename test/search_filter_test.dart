import 'package:flutter_test/flutter_test.dart';
import 'package:sewamobil/core/router/route_names.dart';
import 'package:sewamobil/features/cars/domain/repositories/car_repository.dart';

void main() {
  group('Phase 4 Search, Filter, and Routing Tests', () {
    test('AppRoutes generates car detail and booking paths correctly', () {
      expect(AppRoutes.carDetailPath('car-123'), equals('/cars/car-123'));
      expect(AppRoutes.bookingPath('car-123'), equals('/booking/car-123'));
      expect(AppRoutes.bookingDetailPath('b-456'), equals('/bookings/b-456'));
    });

    test('CarFilterParams handles complex multi-criteria filtering', () {
      final params = const CarFilterParams()
          .copyWith(
            searchQuery: 'Zenix',
            transmission: 'Otomatis',
            fuelType: 'Hybrid',
            minSeats: 7,
            minPrice: 500000,
            maxPrice: 1000000,
            sortBy: 'popular',
          );

      expect(params.searchQuery, equals('Zenix'));
      expect(params.transmission, equals('Otomatis'));
      expect(params.fuelType, equals('Hybrid'));
      expect(params.minSeats, equals(7));
      expect(params.minPrice, equals(500000));
      expect(params.maxPrice, equals(1000000));
      expect(params.sortBy, equals('popular'));
    });
  });
}
