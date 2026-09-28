import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum PaymentCategory {
  bankTransfer,
  qris,
  gateway;

  String get displayName {
    switch (this) {
      case PaymentCategory.bankTransfer:
        return 'Transfer Bank (Verifikasi Manual)';
      case PaymentCategory.qris:
        return 'QRIS & E-Wallet Instant';
      case PaymentCategory.gateway:
        return 'Payment Gateway (Otomatis)';
    }
  }
}

/// Available payment channel definition
class PaymentChannel {
  final String code;
  final String name;
  final String description;
  final PaymentCategory category;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolder;
  final String? qrCodeUrl;
  final IconData icon;
  final Color brandColor;
  final List<String> instructions;

  const PaymentChannel({
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    this.bankName,
    this.accountNumber,
    this.accountHolder,
    this.qrCodeUrl,
    required this.icon,
    this.brandColor = AppColors.primary,
    this.instructions = const [],
  });

  static const List<PaymentChannel> defaultChannels = [
    PaymentChannel(
      code: 'bca_transfer',
      name: 'BCA (Bank Central Asia)',
      description: 'Transfer manual ke rekening resmi BCA CarRent',
      category: PaymentCategory.bankTransfer,
      bankName: 'BCA',
      accountNumber: '8291083921',
      accountHolder: 'PT CARRENT INDONESIA JAYA',
      icon: Icons.account_balance,
      brandColor: Color(0xFF003882),
      instructions: [
        'Buka aplikasi BCA Mobile / KlikBCA / ATM BCA.',
        'Pilih menu Transfer > Antar Rekening BCA.',
        'Masukkan nomor rekening 8291083921 a.n PT CARRENT INDONESIA JAYA.',
        'Masukkan nominal sesuai jumlah tagihan hingga 3 digit terakhir.',
        'Simpan bukti transfer dan unggah melalui form di bawah.',
      ],
    ),
    PaymentChannel(
      code: 'mandiri_transfer',
      name: 'Bank Mandiri',
      description: 'Transfer manual ke rekening resmi Mandiri CarRent',
      category: PaymentCategory.bankTransfer,
      bankName: 'MANDIRI',
      accountNumber: '1370019283741',
      accountHolder: 'PT CARRENT INDONESIA JAYA',
      icon: Icons.account_balance,
      brandColor: Color(0xFF003366),
      instructions: [
        'Buka aplikasi Livin\' by Mandiri atau ATM Mandiri.',
        'Pilih Transfer > Rekening Mandiri.',
        'Masukkan nomor rekening 1370019283741 a.n PT CARRENT INDONESIA JAYA.',
        'Pastikan nominal transfer tepat sesuai invoice.',
        'Unggah screenshot atau foto struk pembayaran.',
      ],
    ),
    PaymentChannel(
      code: 'bri_transfer',
      name: 'Bank BRI',
      description: 'Transfer manual ke rekening resmi BRI CarRent',
      category: PaymentCategory.bankTransfer,
      bankName: 'BRI',
      accountNumber: '034101002938531',
      accountHolder: 'PT CARRENT INDONESIA JAYA',
      icon: Icons.account_balance,
      brandColor: Color(0xFF00529C),
      instructions: [
        'Buka aplikasi BRImo atau ATM BRI.',
        'Pilih Transfer > Tambah Daftar Baru > Masukkan Rekening BRI.',
        'Tujuan rekening: 034101002938531 a.n PT CARRENT INDONESIA JAYA.',
        'Lakukan transfer dengan nominal yang tertera.',
        'Foto struk pembayaran dan lampirkan.',
      ],
    ),
    PaymentChannel(
      code: 'qris',
      name: 'QRIS (Gopay / OVO / Dana / ShopeePay)',
      description: 'Scan kode QRIS dari aplikasi e-wallet atau mobile banking apa saja',
      category: PaymentCategory.qris,
      bankName: 'QRIS',
      accountHolder: 'PT CARRENT INDONESIA JAYA',
      qrCodeUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=400',
      icon: Icons.qr_code_2,
      brandColor: Color(0xFFE5252A),
      instructions: [
        'Buka aplikasi e-wallet Anda (GoPay, OVO, Dana, LinkAja, BCA, dll).',
        'Pilih menu Scan / Bayar menggunakan QR.',
        'Pindai QR code CarRent yang tampil pada layar.',
        'Periksa nama merchant: PT CARRENT INDONESIA JAYA.',
        'Konfirmasi pembayaran dan simpan bukti transfer.',
      ],
    ),
    PaymentChannel(
      code: 'midtrans',
      name: 'Midtrans Payment Gateway (Otomatis)',
      description: 'Bayar instan via Virtual Account atau Kartu Kredit dengan verifikasi langsung',
      category: PaymentCategory.gateway,
      bankName: 'MIDTRANS',
      icon: Icons.flash_on,
      brandColor: Color(0xFF1B6AEB),
      instructions: [
        'Klik tombol "Bayar Sekarang dengan Midtrans".',
        'Pilih metode pembayaran (BCA VA, Mandiri Bill, GoPay, Credit Card).',
        'Selesaikan pembayaran sesuai batas waktu yang diberikan gateway.',
        'Status reservasi akan otomatis berubah menjadi Dikonfirmasi seketika.',
      ],
    ),
  ];
}
