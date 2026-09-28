import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/empty_state.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navBookings)),
      body: const EmptyStateWidget(
        title: AppStrings.emptyBookingsTitle,
        subtitle: AppStrings.emptyBookingsSubtitle,
        icon: Icons.receipt_long_rounded,
      ),
    );
  }
}
