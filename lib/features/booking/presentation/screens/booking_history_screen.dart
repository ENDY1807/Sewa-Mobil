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
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../providers/booking_providers.dart';

/// Full-featured User Booking History Screen with tabs, status filters, and receipt view.
class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<BookingStatus?> _statuses = [
    null, // Semua
    BookingStatus.pending,
    BookingStatus.confirmed,
    BookingStatus.ongoing,
    BookingStatus.completed,
    BookingStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Menunggu'),
            Tab(text: 'Dikonfirmasi'),
            Tab(text: 'Berjalan'),
            Tab(text: 'Selesai'),
            Tab(text: 'Dibatalkan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statuses.map((status) {
          return _BookingTabContent(status: status);
        }).toList(),
      ),
    );
  }
}

class _BookingTabContent extends ConsumerWidget {
  final BookingStatus? status;

  const _BookingTabContent({Key? key, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingsAsync = ref.watch(userBookingsProvider(status));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userBookingsProvider(status));
      },
      child: bookingsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSizes.p20),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p16),
          itemBuilder: (_, __) => const LoadingSkeleton(height: 180),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Text('Gagal memuat pesanan: $err'),
          ),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return EmptyStateWidget(
              title: AppStrings.emptyBookingsTitle,
              subtitle: AppStrings.emptyBookingsSubtitle,
              icon: Icons.receipt_long_rounded,
              action: ElevatedButton(
                onPressed: () => context.push(AppRoutes.explore),
                child: const Text('Sewa Mobil Sekarang'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p20),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p16),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(context, ref, booking, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
    bool isDark,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Code and Status Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.bookingCode,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking.bookingStatus.color.withOpacity(0.12),
                    borderRadius: AppSizes.radiusFull,
                  ),
                  child: Text(
                    booking.bookingStatus.displayName,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: booking.bookingStatus.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Vehicle & Dates
            Text(
              booking.car?.fullTitle ?? 'Mobil Sewa',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormatter.formatDateRange(booking.pickupDate, booking.returnDate),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 8),
                Text('• ${booking.rentalDays} Hari', style: AppTextStyles.bodySmall),
              ],
            ),
            const Divider(height: 20),

            // Price & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(booking.totalPrice),
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (booking.canBeCancelled) ...[
                      TextButton(
                        onPressed: () => _confirmCancel(context, ref, booking.id),
                        child: const Text('Batalkan', style: TextStyle(color: AppColors.error)),
                      ),
                      const SizedBox(width: 8),
                    ],
                    OutlinedButton(
                      onPressed: () => context.push('/bookings/${booking.id}/receipt'),
                      child: const Text('Bukti Sewa'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref, String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pemesanan?'),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan sewa ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kembali')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(bookingControllerProvider.notifier).cancelBooking(bookingId);
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}
