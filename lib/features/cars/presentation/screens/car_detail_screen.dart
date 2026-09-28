import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/price_text.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../providers/car_providers.dart';

/// Premium Car Detail Screen displaying specifications, gallery, pricing tiers, and booking CTA.
class CarDetailScreen extends ConsumerStatefulWidget {
  final String carId;

  const CarDetailScreen({
    Key? key,
    required this.carId,
  }) : super(key: key);

  @override
  ConsumerState<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends ConsumerState<CarDetailScreen> {
  int _activeImageIndex = 0;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final carAsync = ref.watch(carDetailProvider(widget.carId));

    return carAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorStateWidget(
          title: 'Gagal Memuat Detail Kendaraan',
          message: err.toString(),
          onRetry: () => ref.refresh(carDetailProvider(widget.carId)),
        ),
      ),
      data: (car) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Sliver App Bar with Car Visual Header
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                        child: Center(
                          child: Icon(
                            Icons.directions_car_filled_rounded,
                            size: 110,
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                      ),
                      // Gradient overlay for back button contrast
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 90,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black54, Colors.transparent],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Availability Pill on top-right
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: StatusBadge.available(
                          label: car.isAvailable ? AppStrings.statusAvailable : 'Tidak Tersedia',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? AppColors.error : Colors.white,
                    ),
                    onPressed: () {
                      setState(() => _isFavorite = !_isFavorite);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isFavorite
                                ? '${car.model} ditambahkan ke favorit'
                                : '${car.model} dihapus dari favorit',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                  const SizedBox(width: AppSizes.p8),
                ],
              ),

              // Detail Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand & Model Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (car.brand?.name ?? '').toUpperCase(),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isDark ? AppColors.accent : AppColors.primaryLight,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.p4),
                                Text(
                                  car.fullTitle,
                                  style: AppTextStyles.displayMedium.copyWith(fontSize: 22),
                                ),
                                const SizedBox(height: AppSizes.p4),
                                Text(
                                  'Tahun Produksi ${car.year} • ${car.category?.name ?? 'Mobil'}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Rating Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.warningContainer,
                              borderRadius: AppSizes.radiusMd,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  car.rating.toStringAsFixed(1),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p24),

                      // Key Specifications Grid
                      Text('Spesifikasi Kendaraan', style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppSizes.p12),
                      Wrap(
                        spacing: AppSizes.p12,
                        runSpacing: AppSizes.p12,
                        children: [
                          _buildSpecTile(Icons.airline_seat_recline_normal_rounded, 'Kapasitas', '${car.seats} Kursi', isDark),
                          _buildSpecTile(Icons.sync_alt_rounded, 'Transmisi', car.transmission, isDark),
                          _buildSpecTile(Icons.local_gas_station_rounded, 'Bahan Bakar', car.fuelType, isDark),
                          _buildSpecTile(Icons.sensor_door_outlined, 'Pintu', '${car.doors} Pintu', isDark),
                          if (car.engine != null)
                            _buildSpecTile(Icons.engineering_rounded, 'Mesin', car.engine!, isDark),
                          if (car.power != null)
                            _buildSpecTile(Icons.speed_rounded, 'Tenaga', car.power!, isDark),
                          if (car.color != null)
                            _buildSpecTile(Icons.palette_outlined, 'Warna', car.color!, isDark),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p28),

                      // Pricing Tiers Card (Daily, Weekly, Monthly)
                      Text('Paket Harga Sewa', style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppSizes.p12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.p16),
                          child: Column(
                            children: [
                              _buildPriceRow('Sewa Harian', car.dailyPrice, isDark, isHighlight: true),
                              if (car.weeklyPrice != null) ...[
                                const Divider(height: 20),
                                _buildPriceRow('Sewa Mingguan (Hemat)', car.weeklyPrice!, isDark),
                              ],
                              if (car.monthlyPrice != null) ...[
                                const Divider(height: 20),
                                _buildPriceRow('Sewa Bulanan (Korporat)', car.monthlyPrice!, isDark),
                              ],
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Deposit Jaminan (Dapat Dikembalikan)',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(car.deposit),
                                    style: AppTextStyles.labelMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p28),

                      // Features & Facilities
                      if (car.features.isNotEmpty) ...[
                        Text('Fitur & Fasilitas', style: AppTextStyles.titleSmall),
                        const SizedBox(height: AppSizes.p12),
                        Column(
                          children: car.features.map((f) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                                  const SizedBox(width: AppSizes.p12),
                                  Text(f.featureName, style: AppTextStyles.bodyMedium),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSizes.p28),
                      ],

                      // Legal & Open Data Attribution Box
                      Container(
                        padding: const EdgeInsets.all(AppSizes.p16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                          borderRadius: AppSizes.radiusMd,
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_outlined, size: 16, color: AppColors.primaryLight),
                                const SizedBox(width: 8),
                                Text(
                                  'Informasi Legalitas & Lisensi Armada',
                                  style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sumber: ${car.sourceName ?? "Mitra Armada Resmi CarRent"}\nLisensi: ${car.license ?? "Authorized Rental Service"}\nAtribusi: ${car.attribution ?? "CarRent Fleet Ecosystem"}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100), // spacing for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Bar with Rent Now CTA
          bottomSheet: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harga Sewa',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    PriceText(
                      amount: car.dailyPrice,
                      fontSize: 20,
                      isDark: isDark,
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: car.isAvailable
                      ? () => context.push(AppRoutes.bookingPath(car.id))
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p32, vertical: AppSizes.p16),
                  ),
                  child: const Text('Sewa Sekarang'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecTile(IconData icon, String title, String value, bool isDark) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: AppSizes.radiusMd,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryLight),
          const SizedBox(width: AppSizes.p8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, num price, bool isDark, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          CurrencyFormatter.format(price),
          style: AppTextStyles.labelMedium.copyWith(
            color: isHighlight ? AppColors.primaryLight : null,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
