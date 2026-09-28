import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../../cars/data/models/car_model.dart';
import '../../../cars/domain/entities/car.dart';
import '../../domain/repositories/favorites_repository.dart';

/// Concrete implementation of [FavoritesRepository] using Supabase PostgreSQL.
class FavoritesRepositoryImpl implements FavoritesRepository {
  final supa.SupabaseClient _supabase;

  // Local fallback set for guest sessions or instant cache
  final Set<String> _localFavoriteIds = <String>{};

  FavoritesRepositoryImpl(this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<List<Car>> getFavorites() async {
    final userId = _currentUserId;

    if (userId == null) {
      AppLogger.i('Guest user accessing favorites, using local storage.');
      return [];
    }

    try {
      final response = await _supabase
          .from('favorites')
          .select('car_id, cars(*, brands(*), categories(*), car_images(*))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<Car> cars = [];
      _localFavoriteIds.clear();

      for (final item in response as List) {
        final carJson = item['cars'];
        if (carJson != null && carJson is Map<String, dynamic>) {
          final car = CarModel.fromJson(carJson);
          cars.add(car);
          _localFavoriteIds.add(car.id);
        }
      }

      return cars;
    } catch (e, st) {
      AppLogger.w('Failed to fetch favorites from Supabase', e, st);
      return [];
    }
  }

  @override
  Future<bool> isCarFavorite(String carId) async {
    if (_localFavoriteIds.contains(carId)) return true;

    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      final response = await _supabase
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('car_id', carId)
          .maybeSingle();

      final isFav = response != null;
      if (isFav) _localFavoriteIds.add(carId);
      return isFav;
    } catch (e) {
      return _localFavoriteIds.contains(carId);
    }
  }

  @override
  Future<void> addFavorite(String carId) async {
    _localFavoriteIds.add(carId);
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _supabase.from('favorites').upsert(
        {
          'user_id': userId,
          'car_id': carId,
        },
        onConflict: 'user_id, car_id',
      );
      AppLogger.i('Car $carId added to favorites in Supabase');
    } catch (e, st) {
      throw ErrorHandler.handleError(e, st);
    }
  }

  @override
  Future<void> removeFavorite(String carId) async {
    _localFavoriteIds.remove(carId);
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('car_id', carId);
      AppLogger.i('Car $carId removed from favorites in Supabase');
    } catch (e, st) {
      throw ErrorHandler.handleError(e, st);
    }
  }

  @override
  Future<bool> toggleFavorite(String carId) async {
    final isFav = await isCarFavorite(carId);
    if (isFav) {
      await removeFavorite(carId);
      return false;
    } else {
      await addFavorite(carId);
      return true;
    }
  }
}
