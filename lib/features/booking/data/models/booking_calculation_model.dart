import '../../domain/entities/booking_calculation.dart';

class BookingCalculationModel extends BookingCalculation {
  const BookingCalculationModel({
    required int rentalDays,
    required num dailyPrice,
    required num subtotal,
    num discount = 0,
    num deposit = 0,
    required num totalPrice,
  }) : super(
          rentalDays: rentalDays,
          dailyPrice: dailyPrice,
          subtotal: subtotal,
          discount: discount,
          deposit: deposit,
          totalPrice: totalPrice,
        );

  factory BookingCalculationModel.fromJson(Map<String, dynamic> json) {
    return BookingCalculationModel(
      rentalDays: (json['rental_days'] as num).toInt(),
      dailyPrice: json['daily_price'] as num,
      subtotal: json['subtotal'] as num,
      discount: json['discount'] as num? ?? 0,
      deposit: json['deposit'] as num? ?? 0,
      totalPrice: json['total_price'] as num,
    );
  }
}
