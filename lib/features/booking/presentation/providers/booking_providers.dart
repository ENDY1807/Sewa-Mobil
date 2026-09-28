import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/error_handler.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_calculation.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';

/// Provider for the BookingRepository singleton.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final supabase = SupabaseConfig.client;
  return BookingRepositoryImpl(supabase);
});

/// FutureProvider for fetching user bookings with optional status filter.
final userBookingsProvider =
    FutureProvider.family<List<Booking>, BookingStatus?>((ref, status) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getUserBookings(status: status);
});

/// FutureProvider for fetching single booking details.
final bookingDetailProvider =
    FutureProvider.family<Booking, String>((ref, bookingId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getBookingById(bookingId);
});

/// StateNotifier for booking submission and actions.
final bookingControllerProvider =
    StateNotifierProvider<BookingController, AsyncValue<Booking?>>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return BookingController(repo, ref);
});

class BookingController extends StateNotifier<AsyncValue<Booking?>> {
  final BookingRepository _repository;
  final Ref _ref;

  BookingController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<Booking?> submitBooking({
    required String carId,
    required String pickupLocationId,
    required String dropoffLocationId,
    required DateTime pickupDate,
    required DateTime returnDate,
    String? promoCode,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final booking = await _repository.createBooking(
        carId: carId,
        pickupLocationId: pickupLocationId,
        dropoffLocationId: dropoffLocationId,
        pickupDate: pickupDate,
        returnDate: returnDate,
        promoCode: promoCode,
        notes: notes,
      );

      // Invalidate booking lists to refresh data
      _ref.invalidate(userBookingsProvider);
      state = AsyncValue.data(booking);
      return booking;
    } catch (e, st) {
      final appError = ErrorHandler.handleError(e, st);
      state = AsyncValue.error(appError.message, st);
      return null;
    }
  }

  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.cancelBooking(bookingId, reason: reason);
      _ref.invalidate(userBookingsProvider);
      _ref.invalidate(bookingDetailProvider(bookingId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      final appError = ErrorHandler.handleError(e, st);
      state = AsyncValue.error(appError.message, st);
      return false;
    }
  }
}
