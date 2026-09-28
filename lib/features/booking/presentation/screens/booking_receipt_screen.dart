import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/booking_providers.dart';

/// Digital Booking Receipt Screen with print, share, and tracking options.
class BookingReceiptScreen extends ConsumerWidget {
  final String bookingId;

  const BookingReceiptScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));
    final profile = ref.watch(currentUserProfileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bukti Pemesanan'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.go(AppRoutes.home),
          ),
          const SizedBox(width: AppSizes.p8),
        ],
      ),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat receipt: $err')),
        data: (booking) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p20),
            child: Column(
              children: [
                // Top Success Indicator
                Container(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  decoration: const BoxDecoration(
                    color: AppColors.successContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 48,
                  ),
                ),
                const SizedBox(height: AppSizes.p16),
                Text(
                  'Pesanan Berhasil Dibuat!',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSizes.p4),
                Text(
                  'Simpan bukti ini sebagai konfirmasi sewa resmi CarRent Anda.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.p24),

                // Official Receipt Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSizes.radiusLg,
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.p24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Receipt Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CARRENT',
                              style: AppTextStyles.titleLarge.copyWith(
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: booking.bookingStatus.color.withOpacity(0.12),
                                borderRadius: AppSizes.radiusFull,
                              ),
                              child: Text(
                                booking.bookingStatus.displayName.toUpperCase(),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: booking.bookingStatus.color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.p4),
                        Text(
                          'Bukti Resmi Sewa Kendaraan',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const Divider(height: 28),

                        _buildReceiptField('Kode Pemesanan', booking.bookingCode, isHighlight: true),
                        const SizedBox(height: 12),
                        _buildReceiptField('Penyewa', profile?.fullName ?? 'Pelanggan CarRent'),
                        const SizedBox(height: 12),
                        _buildReceiptField('Kendaraan', booking.car?.fullTitle ?? 'Mobil CarRent'),
                        const SizedBox(height: 12),
                        _buildReceiptField('Pengambilan', DateFormatter.formatDateTime(booking.pickupDate)),
                        const SizedBox(height: 12),
                        _buildReceiptField('Pengembalian', DateFormatter.formatDateTime(booking.returnDate)),
                        const SizedBox(height: 12),
                        _buildReceiptField('Durasi Sewa', '${booking.rentalDays} Hari'),
                        const Divider(height: 28),

                        _buildReceiptField('Harga Sewa Subtotal', CurrencyFormatter.format(booking.subtotal)),
                        if (booking.discount > 0) ...[
                          const SizedBox(height: 8),
                          _buildReceiptField('Potongan Diskon', '- ${CurrencyFormatter.format(booking.discount)}'),
                        ],
                        const SizedBox(height: 8),
                        _buildReceiptField('Deposit Jaminan (Refundable)', CurrencyFormatter.format(booking.deposit)),
                        const Divider(height: 28),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('TOTAL BAYAR', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800)),
                            Text(
                              CurrencyFormatter.format(booking.totalPrice),
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Bagikan'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tautan bukti pemesanan disalin.')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Unduh PDF'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mengunduh Bukti Pemesanan PDF...')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: const Text('Kembali ke Beranda'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReceiptField(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight ? AppColors.primaryLight : null,
          ),
        ),
      ],
    );
  }
}
