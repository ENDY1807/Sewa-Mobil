import '../../cars/domain/entities/car.dart';

/// Interface contract for managing user favorite vehicles.
abstract class FavoritesRepository {
  /// Fetch all favorite vehicles for the currently authenticated user.
  Future<List<Car>> getFavorites();

  /// Check whether a specific car is favorited by the current user.
  Future<bool> isCarFavorite(String carId);

  /// Add a car to user favorites.
  Future<void> addFavorite(String carId);

  /// Remove a car from user favorites.
  Future<void> removeFavorite(String carId);

  /// Toggle favorite status for a car; returns the new state (true if favorited).
  Future<bool> toggleFavorite(String carId);
}
