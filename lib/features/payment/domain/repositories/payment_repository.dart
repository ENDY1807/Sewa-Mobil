import '../entities/payment.dart';
import '../entities/payment_channel.dart';

abstract class PaymentRepository {
  /// Fetches existing payment for a specific booking, if any
  Future<Payment?> getPaymentByBookingId(String bookingId);

  /// Initializes a new payment record or updates existing one
  Future<Payment> createOrUpdatePayment({
    required String bookingId,
    required num amount,
    required PaymentChannel channel,
  });

  /// Uploads proof of payment image to Supabase Storage and updates the payment record
  Future<Payment> submitPaymentProof({
    required String bookingId,
    required String paymentId,
    required List<int> fileBytes,
    required String fileName,
  });

  /// Allows direct submission using a proof URL (e.g. for testing/demo or pre-uploaded images)
  Future<Payment> submitPaymentProofUrl({
    required String bookingId,
    required String paymentId,
    required String proofUrl,
  });
}
