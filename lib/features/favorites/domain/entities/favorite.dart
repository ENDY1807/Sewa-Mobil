import '../../cars/domain/entities/car.dart';

/// Pure domain entity representing a user's favorited / bookmarked vehicle.
class Favorite {
  final String id;
  final String userId;
  final String carId;
  final DateTime createdAt;
  final Car? car;

  const Favorite({
    required this.id,
    required this.userId,
    required this.carId,
    required this.createdAt,
    this.car,
  });
}
