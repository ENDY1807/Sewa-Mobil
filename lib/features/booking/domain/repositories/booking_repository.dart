import 'package:flutter/foundation.dart';
import '../entities/booking.dart';
import '../entities/booking_calculation.dart';
import '../entities/booking_status.dart';

/// Contract for Booking lifecycle, Availability checks, and Server-Side pricing.
abstract class BookingRepository {
  /// Check real-time vehicle availability via PostgreSQL anti-overlapping function.
  Future<bool> checkAvailability({
    required String carId,
    required DateTime pickupDate,
    required DateTime returnDate,
  });

  /// Request official server-calculated pricing from PostgreSQL RPC.
  Future<BookingCalculation> calculatePrice({
    required String carId,
    required DateTime pickupDate,
    required DateTime returnDate,
    String? promoCode,
  });

  /// Create a new booking record after server-side validation.
  Future<Booking> createBooking({
    required String carId,
    required String pickupLocationId,
    required String dropoffLocationId,
    required DateTime pickupDate,
    required DateTime returnDate,
    String? promoCode,
    String? notes,
  });

  /// Fetch user booking history with optional status filter.
  Future<List<Booking>> getUserBookings({BookingStatus? status});

  /// Fetch full booking details by ID.
  Future<Booking> getBookingById(String bookingId);

  /// Cancel an active/pending booking.
  Future<void> cancelBooking(String bookingId, {String? reason});
}
