import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/currency_formatter.dart';

/// Reusable formatted price display widget with period label (e.g., Rp 450.000 /hari).
class PriceText extends StatelessWidget {
  final num amount;
  final String period;
  final double fontSize;
  final bool isDark;

  const PriceText({
    Key? key,
    required this.amount,
    this.period = AppStrings.perDay,
    this.fontSize = 18.0,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: CurrencyFormatter.format(amount),
            style: AppTextStyles.priceTag(isDark: isDark, fontSize: fontSize),
          ),
          TextSpan(
            text: ' $period',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
