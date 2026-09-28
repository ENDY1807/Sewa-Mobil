import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/text_styles.dart';

/// Reusable status badge with semantic colors and pill shape.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final IconData? icon;

  const StatusBadge({
    Key? key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.icon,
  }) : super(key: key);

  factory StatusBadge.available({String label = 'Tersedia'}) {
    return StatusBadge(
      label: label,
      color: AppColors.available,
      backgroundColor: AppColors.available.withOpacity(0.12),
      icon: Icons.check_circle_rounded,
    );
  }

  factory StatusBadge.rented({String label = 'Disewa'}) {
    return StatusBadge(
      label: label,
      color: AppColors.rented,
      backgroundColor: AppColors.rented.withOpacity(0.12),
      icon: Icons.directions_car_rounded,
    );
  }

  factory StatusBadge.reserved({String label = 'Dipesan'}) {
    return StatusBadge(
      label: label,
      color: AppColors.reserved,
      backgroundColor: AppColors.reserved.withOpacity(0.12),
      icon: Icons.schedule_rounded,
    );
  }

  factory StatusBadge.maintenance({String label = 'Perawatan'}) {
    return StatusBadge(
      label: label,
      color: AppColors.maintenance,
      backgroundColor: AppColors.maintenance.withOpacity(0.12),
      icon: Icons.build_rounded,
    );
  }

  factory StatusBadge.unavailable({String label = 'Tidak Tersedia'}) {
    return StatusBadge(
      label: label,
      color: AppColors.unavailable,
      backgroundColor: AppColors.unavailable.withOpacity(0.12),
      icon: Icons.cancel_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? color.withOpacity(0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSizes.radiusFull,
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: AppSizes.p4),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
