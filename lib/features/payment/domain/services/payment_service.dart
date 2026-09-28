import '../entities/payment.dart';
import '../entities/payment_channel.dart';
import '../../booking/domain/entities/booking_status.dart';

/// Result object returned by payment service strategies.
class PaymentResult {
  final bool isSuccess;
  final String message;
  final String? transactionId;
  final String? redirectUrl;
  final Payment? payment;

  const PaymentResult({
    required this.isSuccess,
    required this.message,
    this.transactionId,
    this.redirectUrl,
    this.payment,
  });
}

/// Abstract strategy contract for all payment processors.
abstract class PaymentService {
  Future<PaymentResult> initiatePayment({
    required String bookingId,
    required num amount,
    required PaymentChannel channel,
  });

  Future<PaymentResult> verifyOrSubmitProof({
    required String bookingId,
    required String paymentId,
    required String proofUrl,
  });
}

/// Manual Bank Transfer strategy implementation
class ManualTransferService implements PaymentService {
  @override
  Future<PaymentResult> initiatePayment({
    required String bookingId,
    required num amount,
    required PaymentChannel channel,
  }) async {
    // In manual transfer, the user is given instructions and an invoice
    final payment = Payment(
      id: '',
      bookingId: bookingId,
      paymentMethod: channel.code,
      amount: amount,
      bankName: channel.bankName,
      accountNumber: channel.accountNumber,
      accountHolder: channel.accountHolder,
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
    );

    return PaymentResult(
      isSuccess: true,
      message: 'Instruksi pembayaran ${channel.name} telah dibuat.',
      payment: payment,
    );
  }

  @override
  Future<PaymentResult> verifyOrSubmitProof({
    required String bookingId,
    required String paymentId,
    required String proofUrl,
  }) async {
    return PaymentResult(
      isSuccess: true,
      message: 'Bukti transfer berhasil dikirim. Menunggu verifikasi tim admin.',
      transactionId: 'MANUAL-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

/// Midtrans Payment Gateway strategy implementation (Ready for Edge Function / Snap)
class MidtransService implements PaymentService {
  @override
  Future<PaymentResult> initiatePayment({
    required String bookingId,
    required num amount,
    required PaymentChannel channel,
  }) async {
    final mockTxId = 'MIDTRANS-SNAP-${DateTime.now().millisecondsSinceEpoch}';
    final payment = Payment(
      id: '',
      bookingId: bookingId,
      paymentMethod: channel.code,
      amount: amount,
      bankName: 'MIDTRANS',
      status: PaymentStatus.pending,
      transactionId: mockTxId,
      createdAt: DateTime.now(),
    );

    return PaymentResult(
      isSuccess: true,
      message: 'Sesi pembayaran Midtrans berhasil dibuat.',
      transactionId: mockTxId,
      redirectUrl: 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$mockTxId',
      payment: payment,
    );
  }

  @override
  Future<PaymentResult> verifyOrSubmitProof({
    required String bookingId,
    required String paymentId,
    required String proofUrl,
  }) async {
    return const PaymentResult(
      isSuccess: true,
      message: 'Transaksi Midtrans diverifikasi secara otomatis oleh sistem webhook.',
    );
  }
}

/// Xendit Payment Gateway strategy implementation
class XenditService implements PaymentService {
  @override
  Future<PaymentResult> initiatePayment({
    required String bookingId,
    required num amount,
    required PaymentChannel channel,
  }) async {
    final mockInvoiceId = 'XENDIT-INV-${DateTime.now().millisecondsSinceEpoch}';
    final payment = Payment(
      id: '',
      bookingId: bookingId,
      paymentMethod: channel.code,
      amount: amount,
      bankName: 'XENDIT',
      status: PaymentStatus.pending,
      transactionId: mockInvoiceId,
      createdAt: DateTime.now(),
    );

    return PaymentResult(
      isSuccess: true,
      message: 'Invoice Xendit berhasil dibuat.',
      transactionId: mockInvoiceId,
      redirectUrl: 'https://checkout-staging.xendit.co/web/$mockInvoiceId',
      payment: payment,
    );
  }

  @override
  Future<PaymentResult> verifyOrSubmitProof({
    required String bookingId,
    required String paymentId,
    required String proofUrl,
  }) async {
    return const PaymentResult(
      isSuccess: true,
      message: 'Invoice Xendit otomatis diverifikasi melalui callback webhook.',
    );
  }
}
