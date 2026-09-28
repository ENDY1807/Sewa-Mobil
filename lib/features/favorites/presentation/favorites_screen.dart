import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navFavorites)),
      body: const EmptyStateWidget(
        title: AppStrings.emptyFavoritesTitle,
        subtitle: AppStrings.emptyFavoritesSubtitle,
        icon: Icons.favorite_border_rounded,
      ),
    );
  }
}
