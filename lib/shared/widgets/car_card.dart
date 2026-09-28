import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../features/cars/domain/entities/car.dart';
import 'price_text.dart';
import 'status_badge.dart';

/// Reusable Card component for displaying a vehicle in catalog and home screens.
class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const CarCard({
    Key? key,
    required this.car,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSizes.radiusLg,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Brand & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (car.brand?.name ?? '').toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark ? AppColors.accent : AppColors.primaryLight,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${car.model} ${car.variant ?? ''}'.trim(),
                          style: AppTextStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.p8),
                  _buildStatusBadge(car.status),
                ],
              ),
              const SizedBox(height: AppSizes.p12),

              // Visual Area
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: AppSizes.radiusMd,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.directions_car_filled_rounded,
                        size: 72,
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    if (car.category != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: AppSizes.radiusSm,
                          ),
                          child: Text(
                            car.category!.name,
                            style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFavorite ? AppColors.error : (isDark ? Colors.white70 : Colors.black45),
                          size: 20,
                        ),
                        onPressed: onFavoriteTap,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.p16),

              // Specifications Row
              Row(
                children: [
                  _buildSpecItem(
                    icon: Icons.airline_seat_recline_normal_rounded,
                    label: '${car.seats} Kursi',
                    isDark: isDark,
                  ),
                  const SizedBox(width: AppSizes.p12),
                  _buildSpecItem(
                    icon: Icons.sync_alt_rounded,
                    label: car.transmission,
                    isDark: isDark,
                  ),
                  const SizedBox(width: AppSizes.p12),
                  _buildSpecItem(
                    icon: Icons.local_gas_station_rounded,
                    label: car.fuelType,
                    isDark: isDark,
                  ),
                ],
              ),
              const Divider(height: AppSizes.p24),

              // Price & Booking Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PriceText(
                    amount: car.dailyPrice,
                    isDark: isDark,
                  ),
                  ElevatedButton(
                    onPressed: car.isAvailable ? onTap : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p16,
                        vertical: AppSizes.p12,
                      ),
                    ),
                    child: Text(car.isAvailable ? AppStrings.rentNow : 'Tidak Tersedia'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status.toLowerCase()) {
      case 'rented':
        return StatusBadge.rented();
      case 'reserved':
        return StatusBadge.reserved();
      case 'maintenance':
        return StatusBadge.maintenance();
      case 'inactive':
        return StatusBadge.unavailable();
      case 'available':
      default:
        return StatusBadge.available();
    }
  }

  Widget _buildSpecItem({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        ),
        const SizedBox(width: AppSizes.p4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
