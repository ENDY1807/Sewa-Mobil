import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Status lifecycle for bookings matching Supabase `booking_status` ENUM.
enum BookingStatus {
  pending,
  confirmed,
  ongoing,
  completed,
  cancelled,
  rejected;

  static BookingStatus fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'ongoing':
        return BookingStatus.ongoing;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'rejected':
        return BookingStatus.rejected;
      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }

  String get dbValue => name;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Menunggu Konfirmasi';
      case BookingStatus.confirmed:
        return 'Dikonfirmasi';
      case BookingStatus.ongoing:
        return 'Sedang Berjalan';
      case BookingStatus.completed:
        return 'Selesai';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
      case BookingStatus.rejected:
        return 'Ditolak';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.confirmed:
        return AppColors.info;
      case BookingStatus.ongoing:
        return AppColors.rented;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return AppColors.error;
    }
  }
}

/// Payment status matching Supabase `payment_status` ENUM.
enum PaymentStatus {
  unpaid,
  pending,
  paid,
  failed,
  refunded;

  static PaymentStatus fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'unpaid':
      default:
        return PaymentStatus.unpaid;
    }
  }

  String get dbValue => name;

  String get displayName {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Belum Dibayar';
      case PaymentStatus.pending:
        return 'Menunggu Verifikasi';
      case PaymentStatus.paid:
        return 'Lunas';
      case PaymentStatus.failed:
        return 'Gagal';
      case PaymentStatus.refunded:
        return 'Dikembalikan';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.unpaid:
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.refunded:
        return AppColors.textSecondaryLight;
    }
  }
}
