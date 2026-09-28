import 'package:flutter_test/flutter_test.dart';
import 'package:sewamobil/features/booking/domain/entities/booking_calculation.dart';
import 'package:sewamobil/features/booking/domain/entities/booking_status.dart';

void main() {
  group('Phase 6 Booking & Availability Engine Tests', () {
    test('Anti-Overlapping logic accurately identifies conflicting date ranges', () {
      // Existing active reservation: 10 Oct to 15 Oct
      final existingPickup = DateTime(2026, 10, 10);
      final existingReturn = DateTime(2026, 10, 15);

      bool isOverlapping(DateTime reqPickup, DateTime reqReturn) {
        // Anti-overlapping rule: NOT (return_date <= req_pickup OR pickup_date >= req_return)
        return !(existingReturn.isBefore(reqPickup) || existingReturn.isAtSameMomentAs(reqPickup) ||
            existingPickup.isAfter(reqReturn) || existingPickup.isAtSameMomentAs(reqReturn));
      }

      // Conflict Case A: Inside range (11 Oct to 14 Oct) -> Conflict!
      expect(isOverlapping(DateTime(2026, 10, 11), DateTime(2026, 10, 14)), isTrue);

      // Conflict Case B: Overlap start (8 Oct to 12 Oct) -> Conflict!
      expect(isOverlapping(DateTime(2026, 10, 8), DateTime(2026, 10, 12)), isTrue);

      // Conflict Case C: Overlap end (13 Oct to 18 Oct) -> Conflict!
      expect(isOverlapping(DateTime(2026, 10, 13), DateTime(2026, 10, 18)), isTrue);

      // Safe Case A: Completely before (1 Oct to 10 Oct) -> Safe!
      expect(isOverlapping(DateTime(2026, 10, 1), DateTime(2026, 10, 10)), isFalse);

      // Safe Case B: Completely after (15 Oct to 20 Oct) -> Safe!
      expect(isOverlapping(DateTime(2026, 10, 15), DateTime(2026, 10, 20)), isFalse);
    });

    test('BookingCalculation correctly calculates totals with promo and deposit', () {
      final calc = BookingCalculation.fallback(
        days: 4,
        dailyPrice: 750000,
        discount: 300000,
        deposit: 500000,
      );

      expect(calc.rentalDays, equals(4));
      expect(calc.subtotal, equals(3000000)); // 4 * 750k
      expect(calc.discount, equals(300000));
      expect(calc.deposit, equals(500000));
      expect(calc.totalPrice, equals(3200000)); // (3m - 300k) + 500k deposit
    });

    test('BookingStatus and PaymentStatus handle database enum mapping', () {
      expect(BookingStatus.fromString('confirmed'), equals(BookingStatus.confirmed));
      expect(BookingStatus.fromString('ongoing'), equals(BookingStatus.ongoing));
      expect(BookingStatus.fromString('completed'), equals(BookingStatus.completed));
      expect(BookingStatus.fromString('pending'), equals(BookingStatus.pending));

      expect(PaymentStatus.fromString('paid'), equals(PaymentStatus.paid));
      expect(PaymentStatus.fromString('unpaid'), equals(PaymentStatus.unpaid));
      expect(PaymentStatus.fromString('pending'), equals(PaymentStatus.pending));
    });
  });
}
