import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_channel.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../../core/utils/app_logger.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl();
});

final availablePaymentChannelsProvider = Provider<List<PaymentChannel>>((ref) {
  return PaymentChannel.defaultChannels;
});

final selectedPaymentChannelProvider = StateProvider<PaymentChannel>((ref) {
  return PaymentChannel.defaultChannels.first;
});

/// Fetches payment record associated with a given booking ID
final bookingPaymentProvider = FutureProvider.family<Payment?, String>((ref, bookingId) async {
  final repo = ref.watch(paymentRepositoryProvider);
  return await repo.getPaymentByBookingId(bookingId);
});

class PaymentController extends StateNotifier<AsyncValue<Payment?>> {
  final PaymentRepository _repository;
  final Ref _ref;

  PaymentController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<Payment?> initiatePayment({
    required Booking booking,
    required PaymentChannel channel,
  }) async {
    state = const AsyncValue.loading();
    try {
      final payment = await _repository.createOrUpdatePayment(
        bookingId: booking.id,
        amount: booking.totalPrice,
        channel: channel,
      );
      _ref.invalidate(bookingPaymentProvider(booking.id));
      state = AsyncValue.data(payment);
      return payment;
    } catch (e, stack) {
      AppLogger.e('Failed to initiate payment', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<Payment?> submitProofBytes({
    required String bookingId,
    required String paymentId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final payment = await _repository.submitPaymentProof(
        bookingId: bookingId,
        paymentId: paymentId,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      _ref.invalidate(bookingPaymentProvider(bookingId));
      state = AsyncValue.data(payment);
      return payment;
    } catch (e, stack) {
      AppLogger.e('Failed to submit proof bytes', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<Payment?> submitProofUrl({
    required String bookingId,
    required String paymentId,
    required String proofUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final payment = await _repository.submitPaymentProofUrl(
        bookingId: bookingId,
        paymentId: paymentId,
        proofUrl: proofUrl,
      );
      _ref.invalidate(bookingPaymentProvider(bookingId));
      state = AsyncValue.data(payment);
      return payment;
    } catch (e, stack) {
      AppLogger.e('Failed to submit proof url', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
      return null;
    }
  }
}

final paymentControllerProvider =
    StateNotifierProvider<PaymentController, AsyncValue<Payment?>>((ref) {
  final repo = ref.watch(paymentRepositoryProvider);
  return PaymentController(repo, ref);
});
