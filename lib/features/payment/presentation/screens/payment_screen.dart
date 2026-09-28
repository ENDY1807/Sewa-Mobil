import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../booking/domain/entities/booking_status.dart';
import '../../../booking/presentation/providers/booking_providers.dart';
import '../../domain/entities/payment_channel.dart';
import '../providers/payment_providers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const PaymentScreen({super.key, required this.bookingId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  Timer? _timer;
  Duration _remainingTime = const Duration(hours: 2);
  bool _isInitPaymentDone = false;
  final TextEditingController _proofUrlController = TextEditingController();

  // Sample verified demo slips for instantaneous testing in browser/desktop
  static const List<String> _sampleProofs = [
    'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600',
    'https://images.unsplash.com/photo-1554224154-26032ffc0d07?w=600',
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _proofUrlController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('$label berhasil disalin!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingDetailProvider(widget.bookingId));
    final paymentAsync = ref.watch(bookingPaymentProvider(widget.bookingId));
    final selectedChannel = ref.watch(selectedPaymentChannelProvider);
    final channels = ref.watch(availablePaymentChannelsProvider);
    final controllerState = ref.watch(paymentControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Sewa', style: AppTextStyles.titleMedium),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Panduan Pembayaran',
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: bookingAsync.when(
        loading: () => const LoadingSkeleton(),
        error: (err, stack) => ErrorStateWidget(
          message: 'Gagal memuat detail reservasi: $err',
          onRetry: () => ref.invalidate(bookingDetailProvider(widget.bookingId)),
        ),
        data: (booking) {
          if (booking == null) {
            return const ErrorStateWidget(message: 'Data pemesanan tidak ditemukan');
          }

          final payment = paymentAsync.asData?.value;

          // Auto-initiate payment record in background if not yet created
          if (!_isInitPaymentDone && payment == null) {
            _isInitPaymentDone = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(paymentControllerProvider.notifier).initiatePayment(
                    booking: booking,
                    channel: selectedChannel,
                  );
            });
          }

          final isPaid = booking.paymentStatus == PaymentStatus.paid ||
              payment?.status == PaymentStatus.paid;
          final isPending = booking.paymentStatus == PaymentStatus.pending ||
              payment?.status == PaymentStatus.pending;
          final hasProof = payment?.hasProof ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Status Banner if Paid or Pending
                if (isPaid) ...[
                  _buildSuccessPaidCard(booking),
                  const SizedBox(height: 16),
                ] else if (isPending && hasProof) ...[
                  _buildPendingVerificationCard(payment!),
                  const SizedBox(height: 16),
                ],

                // 2. Countdown Timer Bar
                if (!isPaid) ...[
                  _buildCountdownBar(),
                  const SizedBox(height: 16),
                ],

                // 3. Invoice Summary Card
                _buildInvoiceSummaryCard(booking),
                const SizedBox(height: 16),

                // 4. Payment Channel Selector
                if (!isPaid) ...[
                  Text('Pilih Metode Pembayaran', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 8),
                  _buildChannelSelector(channels, selectedChannel, booking),
                  const SizedBox(height: 16),

                  // 5. Account Details & Instructions
                  _buildAccountDetailsCard(selectedChannel, booking),
                  const SizedBox(height: 16),

                  // 6. Proof of Payment Upload Card
                  _buildProofUploadCard(payment, booking, controllerState),
                  const SizedBox(height: 24),
                ],

                // 7. Navigation Actions
                OutlinedButton.icon(
                  onPressed: () => context.go('/bookings/${widget.bookingId}/receipt'),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Lihat Tanda Terima Digital'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/bookings'),
                  child: const Text('Kembali ke Riwayat Pemesanan'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessPaidCard(dynamic booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembayaran Lunas & Terverifikasi!',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reservasi Anda telah dikonfirmasi. Silakan ambil unit mobil sesuai jadwal penjemputan.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingVerificationCard(dynamic payment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hourglass_top, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bukti Bayar Sedang Diverifikasi',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin kami sedang memvalidasi transaksi Anda (rata-rata 5-15 menit). Halaman ini akan otomatis diperbarui.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBar() {
    final isUrgent = _remainingTime.inMinutes < 15;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent ? AppColors.error.withOpacity(0.3) : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            color: isUrgent ? AppColors.error : AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Selesaikan Pembayaran Dalam',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isUrgent ? AppColors.error : null,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isUrgent ? AppColors.error : AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatDuration(_remainingTime),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSummaryCard(dynamic booking) {
    final carName = booking.car?.modelName ?? 'Kendaraan CarRent';
    final carBrand = booking.car?.brand?.name ?? '';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Tagihan', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(booking.totalPrice),
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(
                    booking.totalPrice.toString(),
                    'Nominal tagihan',
                  ),
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text('Salin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kode Booking', style: AppTextStyles.bodySmall),
                Text(
                  booking.bookingCode,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mobil', style: AppTextStyles.bodySmall),
                Text(
                  '$carBrand $carName'.trim(),
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Durasi Sewa', style: AppTextStyles.bodySmall),
                Text('${booking.rentalDays} Hari', style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Jadwal Sewa', style: AppTextStyles.bodySmall),
                Text(
                  '${DateFormatter.formatShort(booking.pickupDate)} - ${DateFormatter.formatShort(booking.returnDate)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelSelector(
    List<PaymentChannel> channels,
    PaymentChannel selected,
    dynamic booking,
  ) {
    return Column(
      children: channels.map((channel) {
        final isSelected = channel.code == selected.code;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              ref.read(selectedPaymentChannelProvider.notifier).state = channel;
              ref.read(paymentControllerProvider.notifier).initiatePayment(
                    booking: booking,
                    channel: channel,
                  );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? channel.brandColor : Theme.of(context).dividerColor.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected ? channel.brandColor.withOpacity(0.04) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: channel.brandColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(channel.icon, color: channel.brandColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          channel.name,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          channel.description,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? channel.brandColor : AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccountDetailsCard(PaymentChannel channel, dynamic booking) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: channel.brandColor.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(channel.icon, color: channel.brandColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Instruksi Pembayaran ${channel.name}',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),

            // If manual bank transfer
            if (channel.category == PaymentCategory.bankTransfer) ...[
              Text('Nomor Rekening Tujuan', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    channel.accountNumber ?? '-',
                    style: AppTextStyles.titleLarge.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: channel.brandColor,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(
                      channel.accountNumber ?? '',
                      'Nomor Rekening ${channel.bankName}',
                    ),
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('Salin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: channel.brandColor,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nama Pemilik Rekening', style: AppTextStyles.caption),
                  Text(
                    channel.accountHolder ?? '-',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // If QRIS
            if (channel.category == PaymentCategory.qris) ...[
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: channel.qrCodeUrl != null
                          ? CachedNetworkImage(
                              imageUrl: channel.qrCodeUrl!,
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.qr_code_2, size: 180),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scan dengan aplikasi perbankan atau e-wallet Anda',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // If Gateway (Midtrans)
            if (channel.category == PaymentCategory.gateway) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pembayaran melalui Midtrans diverifikasi instan secara otomatis via webhook server.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Membuka sesi Midtrans Snap Simulator...'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Buka Midtrans Snap Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: channel.brandColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Step-by-step checklist
            Text('Petunjuk Pembayaran:', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...channel.instructions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}. ',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: channel.brandColor,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProofUploadCard(
    dynamic payment,
    dynamic booking,
    AsyncValue<dynamic> controllerState,
  ) {
    final isLoading = controllerState.isLoading;
    final hasProof = payment?.hasProof ?? false;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Unggah Bukti Transfer', style: AppTextStyles.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan lampirkan foto struk ATM, bukti m-banking, atau screenshot pembayaran untuk divalidasi.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 16),

            if (hasProof) ...[
              // Preview of existing proof
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: CachedNetworkImage(
                    imageUrl: payment.paymentProofUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.receipt, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Bukti transfer telah tersimpan di server',
                    style: AppTextStyles.caption.copyWith(color: AppColors.success),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Input / Demo slip selection
            Text('Pilih Bukti Pembayaran:', style: AppTextStyles.caption),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isLoading || payment == null
                      ? null
                      : () {
                          ref.read(paymentControllerProvider.notifier).submitProofUrl(
                                bookingId: widget.bookingId,
                                paymentId: payment.id,
                                proofUrl: _sampleProofs.first,
                              );
                        },
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Gunakan Bukti Demo #1'),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                OutlinedButton.icon(
                  onPressed: isLoading || payment == null
                      ? null
                      : () {
                          ref.read(paymentControllerProvider.notifier).submitProofUrl(
                                bookingId: widget.bookingId,
                                paymentId: payment.id,
                                proofUrl: _sampleProofs.last,
                              );
                        },
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Gunakan Bukti Demo #2'),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Or custom URL field
            TextField(
              controller: _proofUrlController,
              decoration: InputDecoration(
                labelText: 'Atau Masukkan URL Bukti Pembayaran',
                hintText: 'https://...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isLoading || payment == null
                      ? null
                      : () {
                          final text = _proofUrlController.text.trim();
                          if (text.isNotEmpty) {
                            ref.read(paymentControllerProvider.notifier).submitProofUrl(
                                  bookingId: widget.bookingId,
                                  paymentId: payment.id,
                                  proofUrl: text,
                                );
                            _proofUrlController.clear();
                          }
                        },
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bantuan Pembayaran'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Pastikan Anda mentransfer tepat sesuai nominal.'),
            SizedBox(height: 8),
            Text('2. Verifikasi manual diproses 5-15 menit pada jam kerja (08:00 - 22:00 WIB).'),
            SizedBox(height: 8),
            Text('3. Jika ada kendala, hubungi Customer Care CarRent via WhatsApp di 0812-3456-7890.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}
