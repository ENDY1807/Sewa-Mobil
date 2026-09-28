import '../../../cars/data/models/car_model.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';

class BookingModel extends Booking {
  const BookingModel({
    required String id,
    required String bookingCode,
    required String userId,
    required String carId,
    required String pickupLocationId,
    required String dropoffLocationId,
    required DateTime pickupDate,
    required DateTime returnDate,
    required int rentalDays,
    required num dailyPrice,
    required num subtotal,
    num discount = 0,
    num deposit = 0,
    required num totalPrice,
    PaymentStatus paymentStatus = PaymentStatus.unpaid,
    BookingStatus bookingStatus = BookingStatus.pending,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    CarModel? car,
    String? pickupLocationName,
    String? dropoffLocationName,
  }) : super(
          id: id,
          bookingCode: bookingCode,
          userId: userId,
          carId: carId,
          pickupLocationId: pickupLocationId,
          dropoffLocationId: dropoffLocationId,
          pickupDate: pickupDate,
          returnDate: returnDate,
          rentalDays: rentalDays,
          dailyPrice: dailyPrice,
          subtotal: subtotal,
          discount: discount,
          deposit: deposit,
          totalPrice: totalPrice,
          paymentStatus: paymentStatus,
          bookingStatus: bookingStatus,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
          car: car,
          pickupLocationName: pickupLocationName,
          dropoffLocationName: dropoffLocationName,
        );

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    CarModel? carModel;
    if (json['cars'] != null && json['cars'] is Map<String, dynamic>) {
      carModel = CarModel.fromJson(json['cars'] as Map<String, dynamic>);
    }

    String? pickupName;
    if (json['pickup_location'] != null && json['pickup_location'] is Map<String, dynamic>) {
      pickupName = json['pickup_location']['name'] as String?;
    }

    String? dropoffName;
    if (json['dropoff_location'] != null && json['dropoff_location'] is Map<String, dynamic>) {
      dropoffName = json['dropoff_location']['name'] as String?;
    }

    return BookingModel(
      id: json['id'] as String,
      bookingCode: json['booking_code'] as String,
      userId: json['user_id'] as String,
      carId: json['car_id'] as String,
      pickupLocationId: json['pickup_location_id'] as String,
      dropoffLocationId: json['dropoff_location_id'] as String,
      pickupDate: DateTime.parse(json['pickup_date'] as String),
      returnDate: DateTime.parse(json['return_date'] as String),
      rentalDays: (json['rental_days'] as num).toInt(),
      dailyPrice: json['daily_price'] as num,
      subtotal: json['subtotal'] as num,
      discount: json['discount'] as num? ?? 0,
      deposit: json['deposit'] as num? ?? 0,
      totalPrice: json['total_price'] as num,
      paymentStatus: PaymentStatus.fromString(json['payment_status'] as String?),
      bookingStatus: BookingStatus.fromString(json['booking_status'] as String?),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      car: carModel,
      pickupLocationName: pickupName,
      dropoffLocationName: dropoffName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_code': bookingCode,
      'user_id': userId,
      'car_id': carId,
      'pickup_location_id': pickupLocationId,
      'dropoff_location_id': dropoffLocationId,
      'pickup_date': pickupDate.toIso8601String(),
      'return_date': returnDate.toIso8601String(),
      'rental_days': rentalDays,
      'daily_price': dailyPrice,
      'subtotal': subtotal,
      'discount': discount,
      'deposit': deposit,
      'total_price': totalPrice,
      'payment_status': paymentStatus.dbValue,
      'booking_status': bookingStatus.dbValue,
      'notes': notes,
    };
  }
}
