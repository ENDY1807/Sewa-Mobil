import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_channel.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final SupabaseClient _supabase;

  PaymentRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<Payment?> getPaymentByBookingId(String bookingId) async {
    try {
      final res = await _supabase
          .from('payments')
          .select()
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (res == null) return null;
      return PaymentModel.fromJson(res);
    } catch (e, stack) {
      AppLogger.e('Failed to fetch payment for booking $bookingId', error: e, stackTrace: stack);
      throw AppException('Gagal mengambil data pembayaran: ${e.toString()}');
    }
  }

  @override
  Future<Payment> createOrUpdatePayment({
    required String bookingId,
    required num amount,
    required PaymentChannel channel,
  }) async {
    try {
      final existing = await getPaymentByBookingId(bookingId);

      final payload = {
        'booking_id': bookingId,
        'payment_method': channel.code,
        'amount': amount,
        'bank_name': channel.bankName,
        'account_number': channel.accountNumber,
        'account_holder': channel.accountHolder,
        'status': 'pending',
      };

      Map<String, dynamic> record;
      if (existing != null) {
        final res = await _supabase
            .from('payments')
            .update(payload)
            .eq('id', existing.id)
            .select()
            .single();
        record = res;
      } else {
        final res = await _supabase
            .from('payments')
            .insert(payload)
            .select()
            .single();
        record = res;
      }

      AppLogger.i('Payment initiated successfully for booking: $bookingId');
      return PaymentModel.fromJson(record);
    } catch (e, stack) {
      AppLogger.e('Failed to create or update payment for booking $bookingId', error: e, stackTrace: stack);
      throw AppException('Gagal memproses inisiasi pembayaran: ${e.toString()}');
    }
  }

  @override
  Future<Payment> submitPaymentProof({
    required String bookingId,
    required String paymentId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path = 'payment_proofs/$bookingId/${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';

      // 1. Upload to Supabase Storage bucket 'documents'
      await _supabase.storage.from('documents').uploadBinary(
            path,
            Uint8List.fromList(fileBytes),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = _supabase.storage.from('documents').getPublicUrl(path);

      // 2. Submit payment proof URL
      return await submitPaymentProofUrl(
        bookingId: bookingId,
        paymentId: paymentId,
        proofUrl: publicUrl,
      );
    } catch (e, stack) {
      AppLogger.e('Failed to upload payment proof for booking $bookingId', error: e, stackTrace: stack);
      throw AppException('Gagal mengunggah bukti pembayaran: ${e.toString()}');
    }
  }

  @override
  Future<Payment> submitPaymentProofUrl({
    required String bookingId,
    required String paymentId,
    required String proofUrl,
  }) async {
    try {
      // 1. Update public.payments
      final paymentRes = await _supabase
          .from('payments')
          .update({
            'payment_proof_url': proofUrl,
            'status': 'pending',
          })
          .eq('id', paymentId)
          .select()
          .single();

      // 2. Also ensure public.bookings payment_status reflects 'pending'
      await _supabase
          .from('bookings')
          .update({'payment_status': 'pending'})
          .eq('id', bookingId);

      AppLogger.i('Payment proof attached successfully to payment $paymentId');
      return PaymentModel.fromJson(paymentRes);
    } catch (e, stack) {
      AppLogger.e('Failed to update payment proof record for payment $paymentId', error: e, stackTrace: stack);
      throw AppException('Gagal menyimpan konfirmasi bukti pembayaran: ${e.toString()}');
    }
  }
}
