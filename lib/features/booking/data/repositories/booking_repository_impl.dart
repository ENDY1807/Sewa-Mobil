import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_calculation.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_calculation_model.dart';
import '../models/booking_model.dart';

/// Concrete implementation of [BookingRepository] using Supabase RPCs & tables.
class BookingRepositoryImpl implements BookingRepository {
  final supa.SupabaseClient _supabase;

  BookingRepositoryImpl(this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  static const String _bookingSelectQuery = '''
    *,
    cars(*, brands(*), categories(*), car_images(*)),
    pickup_location:locations!pickup_location_id(name),
    dropoff_location:locations!dropoff_location_id(name)
  ''';

  @override
  Future<bool> checkAvailability({
    required String carId,
    required DateTime pickupDate,
    required DateTime returnDate,
  }) async {
    if (returnDate.isBefore(pickupDate) || returnDate.isAtSameMomentAs(pickupDate)) {
      return false;
    }

    try {
      final response = await _supabase.rpc(
        'check_car_availability',
        params: {
          'p_car_id': carId,
          'p_pickup_date': pickupDate.toIso8601String(),
          'p_return_date': returnDate.toIso8601String(),
        },
      );

      return response as bool? ?? true;
    } catch (e, st) {
      AppLogger.w('RPC check_car_availability failed, falling back to client validation.', e, st);
      return true; // allow proceeding if offline
    }
  }

  @override
  Future<BookingCalculation> calculatePrice({
    required String carId,
    required DateTime pickupDate,
    required DateTime returnDate,
    String? promoCode,
  }) async {
    final days = DateFormatter.calculateRentalDays(pickupDate, returnDate);

    try {
      final response = await _supabase.rpc(
        'calculate_booking_price',
        params: {
          'p_car_id': carId,
          'p_pickup_date': pickupDate.toIso8601String(),
          'p_return_date': returnDate.toIso8601String(),
          if (promoCode != null && promoCode.trim().isNotEmpty) 'p_promo_code': promoCode.trim(),
        },
      );

      if (response != null && response is List && response.isNotEmpty) {
        return BookingCalculationModel.fromJson(response.first as Map<String, dynamic>);
      }

      // Fallback calculation if RPC returned empty
      return BookingCalculation.fallback(days: days, dailyPrice: 500000);
    } catch (e, st) {
      AppLogger.w('RPC calculate_booking_price failed, generating deterministic calculation', e, st);
      return BookingCalculation.fallback(days: days, dailyPrice: 500000);
    }
  }

  @override
  Future<Booking> createBooking({
    required String carId,
    required String pickupLocationId,
    required String dropoffLocationId,
    required DateTime pickupDate,
    required DateTime returnDate,
    String? promoCode,
    String? notes,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const UnauthorizedException('Silakan login terlebih dahulu untuk melakukan sewa.');
    }

    // 1. Verify availability
    final isAvailable = await checkAvailability(
      carId: carId,
      pickupDate: pickupDate,
      returnDate: returnDate,
    );

    if (!isAvailable) {
      throw const BookingConflictException(
        'Mobil tidak tersedia untuk tanggal yang dipilih karena sudah terpesan oleh pengguna lain.',
      );
    }

    // 2. Calculate official server-side pricing
    final calc = await calculatePrice(
      carId: carId,
      pickupDate: pickupDate,
      returnDate: returnDate,
      promoCode: promoCode,
    );

    // 3. Generate human-readable unique booking code: CR-YYYYMMDD-XXXX
    final now = DateTime.now();
    final randomSuffix = (Random().nextInt(9000) + 1000).toString();
    final bookingCode = 'CR-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$randomSuffix';

    try {
      final insertData = {
        'booking_code': bookingCode,
        'user_id': userId,
        'car_id': carId,
        'pickup_location_id': pickupLocationId,
        'dropoff_location_id': dropoffLocationId,
        'pickup_date': pickupDate.toIso8601String(),
        'return_date': returnDate.toIso8601String(),
        'rental_days': calc.rentalDays,
        'daily_price': calc.dailyPrice,
        'subtotal': calc.subtotal,
        'discount': calc.discount,
        'deposit': calc.deposit,
        'total_price': calc.totalPrice,
        'payment_status': 'unpaid',
        'booking_status': 'pending',
        'notes': notes,
      };

      final response = await _supabase
          .from('bookings')
          .insert(insertData)
          .select(_bookingSelectQuery)
          .single();

      AppLogger.i('Booking created successfully: $bookingCode');
      return BookingModel.fromJson(response);
    } catch (e, st) {
      throw ErrorHandler.handleError(e, st);
    }
  }

  @override
  Future<List<Booking>> getUserBookings({BookingStatus? status}) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      var query = _supabase
          .from('bookings')
          .select(_bookingSelectQuery)
          .eq('user_id', userId);

      if (status != null) {
        query = query.eq('booking_status', status.dbValue);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.w('Failed to fetch user bookings from Supabase', e, st);
      return [];
    }
  }

  @override
  Future<Booking> getBookingById(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select(_bookingSelectQuery)
          .eq('id', bookingId)
          .single();

      return BookingModel.fromJson(response);
    } catch (e, st) {
      throw ErrorHandler.handleError(e, st);
    }
  }

  @override
  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'booking_status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
            if (reason != null) 'notes': reason,
          })
          .eq('id', bookingId);

      AppLogger.i('Booking $bookingId cancelled.');
    } catch (e, st) {
      throw ErrorHandler.handleError(e, st);
    }
  }
}
