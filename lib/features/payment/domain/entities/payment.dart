import '../../booking/domain/entities/booking_status.dart';

/// Pure domain entity representing a payment record.
class Payment {
  final String id;
  final String bookingId;
  final String paymentMethod;
  final num amount;
  final String? paymentProofUrl;
  final PaymentStatus status;
  final String? transactionId;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.paymentMethod,
    required this.amount,
    this.paymentProofUrl,
    this.status = PaymentStatus.pending,
    this.transactionId,
    this.bankName,
    this.accountNumber,
    this.accountHolder,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPaid => status == PaymentStatus.paid;
  bool get isPending => status == PaymentStatus.pending;
  bool get hasProof => paymentProofUrl != null && paymentProofUrl!.trim().isNotEmpty;
}
