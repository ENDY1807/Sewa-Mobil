import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/empty_state.dart';

/// Catalog / Explore screen placeholder for Phase 1.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Kendaraan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filter',
            onPressed: () {},
          ),
        ],
      ),
      body: const EmptyStateWidget(
        title: AppStrings.emptyCarsTitle,
        subtitle: 'Katalog kendaraan lengkap akan dimuat pada Phase 3 & 4 setelah database migration.',
        icon: Icons.directions_car_rounded,
      ),
    );
  }
}
