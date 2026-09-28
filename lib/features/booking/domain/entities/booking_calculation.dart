/// Value object representing the official server-calculated pricing breakdown.
/// Ensures client-side price manipulation is strictly prevented.
class BookingCalculation {
  final int rentalDays;
  final num dailyPrice;
  final num subtotal;
  final num discount;
  final num deposit;
  final num totalPrice;

  const BookingCalculation({
    required this.rentalDays,
    required this.dailyPrice,
    required this.subtotal,
    this.discount = 0,
    this.deposit = 0,
    required this.totalPrice,
  });

  factory BookingCalculation.fallback({
    required int days,
    required num dailyPrice,
    num deposit = 0,
    num discount = 0,
  }) {
    final sub = days * dailyPrice;
    return BookingCalculation(
      rentalDays: days,
      dailyPrice: dailyPrice,
      subtotal: sub,
      discount: discount,
      deposit: deposit,
      totalPrice: (sub - discount) + deposit,
    );
  }
}
