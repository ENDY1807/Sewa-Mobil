import '../../cars/domain/entities/car.dart';
import 'booking_status.dart';

/// Pure domain entity representing a car rental booking in CarRent.
class Booking {
  final String id;
  final String bookingCode;
  final String userId;
  final String carId;
  final String pickupLocationId;
  final String dropoffLocationId;
  final DateTime pickupDate;
  final DateTime returnDate;
  final int rentalDays;
  final num dailyPrice;
  final num subtotal;
  final num discount;
  final num deposit;
  final num totalPrice;
  final PaymentStatus paymentStatus;
  final BookingStatus bookingStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined Relations
  final Car? car;
  final String? pickupLocationName;
  final String? dropoffLocationName;

  const Booking({
    required this.id,
    required this.bookingCode,
    required this.userId,
    required this.carId,
    required this.pickupLocationId,
    required this.dropoffLocationId,
    required this.pickupDate,
    required this.returnDate,
    required this.rentalDays,
    required this.dailyPrice,
    required this.subtotal,
    this.discount = 0,
    this.deposit = 0,
    required this.totalPrice,
    this.paymentStatus = PaymentStatus.unpaid,
    this.bookingStatus = BookingStatus.pending,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.car,
    this.pickupLocationName,
    this.dropoffLocationName,
  });

  bool get canBeCancelled =>
      bookingStatus == BookingStatus.pending || bookingStatus == BookingStatus.confirmed;

  bool get isCompleted => bookingStatus == BookingStatus.completed;
}
