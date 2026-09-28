import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/repositories/car_repository.dart';
import '../providers/car_providers.dart';

/// Interactive Material 3 BottomSheet for comprehensive catalog filtering.
class FilterBottomSheet extends ConsumerStatefulWidget {
  final CarFilterParams initialParams;
  final ValueChanged<CarFilterParams> onApply;

  const FilterBottomSheet({
    Key? key,
    required this.initialParams,
    required this.onApply,
  }) : super(key: key);

  static Future<CarFilterParams?> show(
    BuildContext context,
    CarFilterParams initialParams,
  ) {
    return showModalBottomSheet<CarFilterParams>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialParams: initialParams,
        onApply: (params) => Navigator.pop(context, params),
      ),
    );
  }

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late String? _selectedBrandId;
  late String? _selectedCategoryId;
  late RangeValues _priceRange;
  late String? _transmission;
  late String? _fuelType;
  late int? _minSeats;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _selectedBrandId = widget.initialParams.brandId;
    _selectedCategoryId = widget.initialParams.categoryId;
    _priceRange = RangeValues(
      widget.initialParams.minPrice?.toDouble() ?? 250000,
      widget.initialParams.maxPrice?.toDouble() ?? 5000000,
    );
    _transmission = widget.initialParams.transmission;
    _fuelType = widget.initialParams.fuelType;
    _minSeats = widget.initialParams.minSeats;
    _sortBy = widget.initialParams.sortBy ?? 'recommended';
  }

  void _resetFilters() {
    setState(() {
      _selectedBrandId = null;
      _selectedCategoryId = null;
      _priceRange = const RangeValues(250000, 5000000);
      _transmission = null;
      _fuelType = null;
      _minSeats = null;
      _sortBy = 'recommended';
    });
  }

  void _applyFilters() {
    final updated = widget.initialParams.copyWith(
      brandId: _selectedBrandId,
      categoryId: _selectedCategoryId,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      transmission: _transmission,
      fuelType: _fuelType,
      minSeats: _minSeats,
      sortBy: _sortBy,
      page: 1, // reset to first page on filter change
    );
    widget.onApply(updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandsAsync = ref.watch(brandsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.r24)),
      ),
      child: Column(
        children: [
          // Header with drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: AppSizes.radiusFull,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter & Urutkan', style: AppTextStyles.titleMedium),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Filter Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.p20),
              children: [
                // Urutkan (Sort By)
                _buildSectionTitle('Urutkan Berdasarkan', isDark),
                const SizedBox(height: AppSizes.p12),
                Wrap(
                  spacing: AppSizes.p8,
                  runSpacing: AppSizes.p8,
                  children: [
                    _buildSortChip('Rekomendasi', 'recommended', isDark),
                    _buildSortChip('Harga Terendah', 'price_asc', isDark),
                    _buildSortChip('Harga Tertinggi', 'price_desc', isDark),
                    _buildSortChip('Paling Populer', 'popular', isDark),
                    _buildSortChip('Tahun Terbaru', 'newest', isDark),
                    _buildSortChip('Rating Tertinggi', 'rating', isDark),
                  ],
                ),
                const SizedBox(height: AppSizes.p24),

                // Kategori
                _buildSectionTitle('Kategori Kendaraan', isDark),
                const SizedBox(height: AppSizes.p12),
                categoriesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Gagal memuat kategori'),
                  data: (categories) => Wrap(
                    spacing: AppSizes.p8,
                    runSpacing: AppSizes.p8,
                    children: categories.map((cat) {
                      final isSelected = _selectedCategoryId == cat.id;
                      return ChoiceChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => _selectedCategoryId = val ? cat.id : null);
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSizes.p24),

                // Brand
                _buildSectionTitle('Merek / Brand', isDark),
                const SizedBox(height: AppSizes.p12),
                brandsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Gagal memuat merek'),
                  data: (brands) => Wrap(
                    spacing: AppSizes.p8,
                    runSpacing: AppSizes.p8,
                    children: brands.map((b) {
                      final isSelected = _selectedBrandId == b.id;
                      return ChoiceChip(
                        label: Text(b.name),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => _selectedBrandId = val ? b.id : null);
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSizes.p24),

                // Rentang Harga
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Rentang Harga Sewa (Per Hari)', isDark),
                    Text(
                      '${CurrencyFormatter.formatCompact(_priceRange.start)} - ${CurrencyFormatter.formatCompact(_priceRange.end)}',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryLight),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 250000,
                  max: 10000000,
                  divisions: 39,
                  labels: RangeLabels(
                    CurrencyFormatter.formatCompact(_priceRange.start),
                    CurrencyFormatter.formatCompact(_priceRange.end),
                  ),
                  onChanged: (values) => setState(() => _priceRange = values),
                ),
                const SizedBox(height: AppSizes.p20),

                // Transmisi
                _buildSectionTitle('Transmisi', isDark),
                const SizedBox(height: AppSizes.p12),
                Wrap(
                  spacing: AppSizes.p8,
                  children: [
                    _buildChoiceChip('Semua Transmisi', _transmission == null, () => setState(() => _transmission = null)),
                    _buildChoiceChip('Otomatis', _transmission == 'Otomatis', () => setState(() => _transmission = 'Otomatis')),
                    _buildChoiceChip('Manual', _transmission == 'Manual', () => setState(() => _transmission = 'Manual')),
                  ],
                ),
                const SizedBox(height: AppSizes.p20),

                // Bahan Bakar
                _buildSectionTitle('Jenis Bahan Bakar', isDark),
                const SizedBox(height: AppSizes.p12),
                Wrap(
                  spacing: AppSizes.p8,
                  runSpacing: AppSizes.p8,
                  children: [
                    _buildChoiceChip('Semua', _fuelType == null, () => setState(() => _fuelType = null)),
                    _buildChoiceChip('Bensin', _fuelType == 'Bensin', () => setState(() => _fuelType = 'Bensin')),
                    _buildChoiceChip('Diesel', _fuelType == 'Diesel', () => setState(() => _fuelType = 'Diesel')),
                    _buildChoiceChip('Hybrid', _fuelType == 'Hybrid', () => setState(() => _fuelType = 'Hybrid')),
                    _buildChoiceChip('Electric (EV)', _fuelType == 'Electric', () => setState(() => _fuelType = 'Electric')),
                  ],
                ),
                const SizedBox(height: AppSizes.p20),

                // Kapasitas Kursi
                _buildSectionTitle('Kapasitas Kursi Minimal', isDark),
                const SizedBox(height: AppSizes.p12),
                Wrap(
                  spacing: AppSizes.p8,
                  children: [
                    _buildChoiceChip('Semua', _minSeats == null, () => setState(() => _minSeats = null)),
                    _buildChoiceChip('4 Kursi', _minSeats == 4, () => setState(() => _minSeats = 4)),
                    _buildChoiceChip('5 Kursi', _minSeats == 5, () => setState(() => _minSeats = 5)),
                    _buildChoiceChip('7+ Kursi', _minSeats == 7, () => setState(() => _minSeats = 7)),
                  ],
                ),
                const SizedBox(height: AppSizes.p32),
              ],
            ),
          ),

          // Bottom Fixed Action Button
          Container(
            padding: const EdgeInsets.all(AppSizes.p20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Terapkan Filter Kendaraan'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(fontSize: 15),
    );
  }

  Widget _buildSortChip(String label, String value, bool isDark) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _sortBy = value);
      },
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
    );
  }
}
