import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sewamobil/features/booking/domain/entities/booking_status.dart';
import 'package:sewamobil/features/payment/data/models/payment_model.dart';
import 'package:sewamobil/features/payment/domain/entities/payment_channel.dart';
import 'package:sewamobil/features/payment/domain/services/payment_service.dart';

void main() {
  group('Phase 7 Payment Tests', () {
    test('PaymentChannel defaults contain Indonesian banks, QRIS, and Midtrans', () {
      final channels = PaymentChannel.defaultChannels;
      expect(channels.length, greaterThanOrEqualTo(5));

      final codes = channels.map((c) => c.code).toList();
      expect(codes, contains('bca_transfer'));
      expect(codes, contains('mandiri_transfer'));
      expect(codes, contains('bri_transfer'));
      expect(codes, contains('qris'));
      expect(codes, contains('midtrans'));

      final bca = channels.firstWhere((c) => c.code == 'bca_transfer');
      expect(bca.accountNumber, isNotEmpty);
      expect(bca.accountHolder, contains('CARRENT'));
      expect(bca.category, equals(PaymentCategory.bankTransfer));
      expect(bca.instructions, isNotEmpty);
    });

    test('PaymentModel serializes and deserializes correctly to/from Supabase JSON', () {
      final json = {
        'id': 'pay-001',
        'booking_id': 'book-123',
        'payment_method': 'bca_transfer',
        'amount': 1500000,
        'payment_proof_url': 'https://storage.supabase.co/documents/proof.jpg',
        'status': 'pending',
        'transaction_id': 'TX-9999',
        'bank_name': 'BCA',
        'account_number': '8291083921',
        'account_holder': 'PT CARRENT INDONESIA JAYA',
        'created_at': '2026-09-29T10:00:00Z',
      };

      final payment = PaymentModel.fromJson(json);

      expect(payment.id, equals('pay-001'));
      expect(payment.bookingId, equals('book-123'));
      expect(payment.paymentMethod, equals('bca_transfer'));
      expect(payment.amount, equals(1500000));
      expect(payment.status, equals(PaymentStatus.pending));
      expect(payment.hasProof, isTrue);
      expect(payment.isPaid, isFalse);
      expect(payment.bankName, equals('BCA'));

      final serialized = payment.toJson();
      expect(serialized['id'], equals('pay-001'));
      expect(serialized['booking_id'], equals('book-123'));
      expect(serialized['payment_method'], equals('bca_transfer'));
      expect(serialized['status'], equals('pending'));
      expect(serialized['amount'], equals(1500000));
    });

    test('ManualTransferService initiates payment with correct bank and status', () async {
      final service = ManualTransferService();
      final channel = PaymentChannel.defaultChannels.firstWhere((c) => c.code == 'bca_transfer');

      final result = await service.initiatePayment(
        bookingId: 'book-456',
        amount: 850000,
        channel: channel,
      );

      expect(result.isSuccess, isTrue);
      expect(result.payment, isNotNull);
      expect(result.payment!.bookingId, equals('book-456'));
      expect(result.payment!.amount, equals(850000));
      expect(result.payment!.bankName, equals('BCA'));
      expect(result.payment!.accountNumber, equals(channel.accountNumber));
      expect(result.payment!.status, equals(PaymentStatus.pending));
    });

    test('MidtransService initiates mock snap token session', () async {
      final service = MidtransService();
      final channel = PaymentChannel.defaultChannels.firstWhere((c) => c.code == 'midtrans');

      final result = await service.initiatePayment(
        bookingId: 'book-789',
        amount: 2500000,
        channel: channel,
      );

      expect(result.isSuccess, isTrue);
      expect(result.transactionId, isNotNull);
      expect(result.transactionId, contains('MIDTRANS'));
      expect(result.redirectUrl, contains('midtrans.com'));
      expect(result.payment!.bankName, equals('MIDTRANS'));
    });

    test('XenditService initiates mock invoice session', () async {
      final service = XenditService();
      const channel = PaymentChannel(
        code: 'xendit',
        name: 'Xendit Invoice',
        description: 'Invoice checkout',
        category: PaymentCategory.gateway,
        icon: Icons.receipt_long,
      );

      final result = await service.initiatePayment(
        bookingId: 'book-999',
        amount: 500000,
        channel: channel,
      );

      expect(result.isSuccess, isTrue);
      expect(result.transactionId, contains('XENDIT'));
      expect(result.redirectUrl, contains('xendit.co'));
    });
  });
}
