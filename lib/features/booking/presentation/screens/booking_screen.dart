import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../cars/presentation/providers/car_providers.dart';
import '../../domain/entities/booking_calculation.dart';
import '../providers/booking_providers.dart';

/// Full-featured interactive Booking Wizard screen.
class BookingScreen extends ConsumerStatefulWidget {
  final String carId;

  const BookingScreen({
    Key? key,
    required this.carId,
  }) : super(key: key);

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _pickupDate = DateTime.now().add(const Duration(days: 1));
  DateTime _returnDate = DateTime.now().add(const Duration(days: 4));
  String _pickupLocationId = 'l0000001-0000-0000-0000-000000000001';
  String _dropoffLocationId = 'l0000001-0000-0000-0000-000000000001';
  final _promoController = TextEditingController();
  final _notesController = TextEditingController();

  BookingCalculation? _calculation;
  bool _isCalculating = false;

  final List<Map<String, String>> _locations = [
    {'id': 'l0000001-0000-0000-0000-000000000001', 'name': 'Pool Jakarta Pusat (Sudirman)'},
    {'id': 'l0000001-0000-0000-0000-000000000002', 'name': 'Bandara Soekarno-Hatta Terminal 3'},
    {'id': 'l0000001-0000-0000-0000-000000000003', 'name': 'Pool Surabaya Juanda'},
    {'id': 'l0000001-0000-0000-0000-000000000004', 'name': 'Pool Denpasar Bali (Kuta)'},
    {'id': 'l0000001-0000-0000-0000-000000000005', 'name': 'Pool Bandung Dago'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchPricing();
  }

  @override
  void dispose() {
    _promoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchPricing() async {
    setState(() => _isCalculating = true);
    final repo = ref.read(bookingRepositoryProvider);
    final calc = await repo.calculatePrice(
      carId: widget.carId,
      pickupDate: _pickupDate,
      returnDate: _returnDate,
      promoCode: _promoController.text.trim().isNotEmpty ? _promoController.text.trim() : null,
    );
    if (mounted) {
      setState(() {
        _calculation = calc;
        _isCalculating = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: DateTimeRange(start: _pickupDate, end: _returnDate),
    );

    if (picked != null) {
      setState(() {
        _pickupDate = picked.start;
        _returnDate = picked.end;
      });
      _fetchPricing();
    }
  }

  Future<void> _handleSubmit() async {
    final booking = await ref.read(bookingControllerProvider.notifier).submitBooking(
          carId: widget.carId,
          pickupLocationId: _pickupLocationId,
          dropoffLocationId: _dropoffLocationId,
          pickupDate: _pickupDate,
          returnDate: _returnDate,
          promoCode: _promoController.text.trim().isNotEmpty ? _promoController.text.trim() : null,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );

    if (!mounted) return;

    if (booking != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemesanan berhasil dibuat!'),
          backgroundColor: AppColors.success,
        ),
      );
      // Navigate to payment screen
      context.go('/booking/${booking.id}/payment');
    } else {
      final errorState = ref.read(bookingControllerProvider);
      final errorMsg = errorState.hasError ? errorState.error.toString() : 'Gagal membuat pesanan.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final carAsync = ref.watch(carDetailProvider(widget.carId));
    final bookingState = ref.watch(bookingControllerProvider);
    final isSubmitting = bookingState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Sewa Mobil')),
      body: carAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal: $err')),
        data: (car) {
          final rentalDays = DateFormatter.calculateRentalDays(_pickupDate, _returnDate);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Summary Banner
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                            borderRadius: AppSizes.radiusMd,
                          ),
                          child: const Icon(Icons.directions_car_filled_rounded, size: 36),
                        ),
                        const SizedBox(width: AppSizes.p16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (car.brand?.name ?? '').toUpperCase(),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(car.fullTitle, style: AppTextStyles.titleSmall),
                              Text(
                                '${car.seats} Kursi • ${car.transmission} • ${car.fuelType}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p24),

                // Location Selection
                Text('Lokasi Pengambilan & Pengembalian', style: AppTextStyles.titleSmall),
                const SizedBox(height: AppSizes.p12),
                DropdownButtonFormField<String>(
                  value: _pickupLocationId,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi Pengambilan (Pick-up)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: _locations.map((loc) {
                    return DropdownMenuItem(value: loc['id'], child: Text(loc['name']!));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _pickupLocationId = val);
                  },
                ),
                const SizedBox(height: AppSizes.p12),
                DropdownButtonFormField<String>(
                  value: _dropoffLocationId,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi Pengembalian (Drop-off)',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: _locations.map((loc) {
                    return DropdownMenuItem(value: loc['id'], child: Text(loc['name']!));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _dropoffLocationId = val);
                  },
                ),
                const SizedBox(height: AppSizes.p24),

                // Date Selection Card
                Text('Jadwal Waktu Sewa', style: AppTextStyles.titleSmall),
                const SizedBox(height: AppSizes.p12),
                InkWell(
                  onTap: _selectDateRange,
                  borderRadius: AppSizes.radiusMd,
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      borderRadius: AppSizes.radiusMd,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal Sewa ($rentalDays Hari)',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormatter.formatDateRange(_pickupDate, _returnDate),
                              style: AppTextStyles.titleSmall,
                            ),
                          ],
                        ),
                        const Icon(Icons.calendar_today_rounded, color: AppColors.primaryLight, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p24),

                // Promo Code Section
                Text('Kode Promo / Diskon', style: AppTextStyles.titleSmall),
                const SizedBox(height: AppSizes.p12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: CARRENTMERDEKA',
                          prefixIcon: Icon(Icons.local_offer_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSizes.p12),
                    ElevatedButton(
                      onPressed: _fetchPricing,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
                      ),
                      child: const Text('Gunakan'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p24),

                // Server-Calculated Price Breakdown
                Text('Rincian Pembayaran', style: AppTextStyles.titleSmall),
                const SizedBox(height: AppSizes.p12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.p20),
                    child: _isCalculating
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              _buildSummaryRow(
                                'Sewa ${car.fullTitle} ($rentalDays Hari)',
                                _calculation?.subtotal ?? (rentalDays * car.dailyPrice),
                              ),
                              if ((_calculation?.discount ?? 0) > 0) ...[
                                const SizedBox(height: 10),
                                _buildSummaryRow('Diskon Promosi', -(_calculation!.discount), isDiscount: true),
                              ],
                              const SizedBox(height: 10),
                              _buildSummaryRow('Deposit Jaminan (Refundable)', _calculation?.deposit ?? car.deposit),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Pembayaran',
                                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(_calculation?.totalPrice ?? ((rentalDays * car.dailyPrice) + car.deposit)),
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppSizes.p32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Konfirmasi & Buat Pesanan'),
                  ),
                ),
                const SizedBox(height: AppSizes.p32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, num amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          isDiscount ? '- ${CurrencyFormatter.format(amount.abs())}' : CurrencyFormatter.format(amount),
          style: AppTextStyles.labelMedium.copyWith(
            color: isDiscount ? AppColors.success : null,
            fontWeight: isDiscount ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
