import 'package:flutter_test/flutter_test.dart';
import 'package:sewamobil/features/cars/domain/entities/car.dart';
import 'package:sewamobil/features/favorites/domain/entities/favorite.dart';

void main() {
  group('Phase 5 Favorites Domain Tests', () {
    test('Favorite entity instantiates correctly with car association', () {
      final now = DateTime.now();
      final car = Car(
        id: 'car-1',
        brandId: 'b-1',
        categoryId: 'c-1',
        model: 'Avanza',
        year: 2023,
        transmission: 'Otomatis',
        fuelType: 'Bensin',
        seats: 7,
        dailyPrice: 450000,
        createdAt: now,
        updatedAt: now,
      );

      final favorite = Favorite(
        id: 'fav-100',
        userId: 'user-001',
        carId: 'car-1',
        createdAt: now,
        car: car,
      );

      expect(favorite.id, equals('fav-100'));
      expect(favorite.userId, equals('user-001'));
      expect(favorite.carId, equals('car-1'));
      expect(favorite.car?.model, equals('Avanza'));
      expect(favorite.car?.dailyPrice, equals(450000));
    });

    test('Local set maintains unique car favorite entries', () {
      final Set<String> favorites = {};

      // Add
      favorites.add('car-1');
      favorites.add('car-2');
      expect(favorites.contains('car-1'), isTrue);
      expect(favorites.length, equals(2));

      // Duplicate add doesn't duplicate
      favorites.add('car-1');
      expect(favorites.length, equals(2));

      // Remove
      favorites.remove('car-1');
      expect(favorites.contains('car-1'), isFalse);
      expect(favorites.length, equals(1));
    });
  });
}
