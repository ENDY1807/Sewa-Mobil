import '../../booking/domain/entities/booking_status.dart';
import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.bookingId,
    required super.paymentMethod,
    required super.amount,
    super.paymentProofUrl,
    super.status = PaymentStatus.pending,
    super.transactionId,
    super.bankName,
    super.accountNumber,
    super.accountHolder,
    required super.createdAt,
    super.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      paymentMethod: json['payment_method'] as String? ?? 'bank_transfer',
      amount: json['amount'] as num,
      paymentProofUrl: json['payment_proof_url'] as String?,
      status: PaymentStatus.fromString(json['status'] as String?),
      transactionId: json['transaction_id'] as String?,
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      accountHolder: json['account_holder'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'booking_id': bookingId,
      'payment_method': paymentMethod,
      'amount': amount,
      'payment_proof_url': paymentProofUrl,
      'status': status.dbValue,
      'transaction_id': transactionId,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_holder': accountHolder,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    String? paymentMethod,
    num? amount,
    String? paymentProofUrl,
    PaymentStatus? status,
    String? transactionId,
    String? bankName,
    String? accountNumber,
    String? accountHolder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolder: accountHolder ?? this.accountHolder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
