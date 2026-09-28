import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewamobil/core/constants/app_strings.dart';
import 'package:sewamobil/core/utils/currency_formatter.dart';
import 'package:sewamobil/core/utils/date_formatter.dart';
import 'package:sewamobil/main.dart';
import 'package:sewamobil/shared/widgets/price_text.dart';
import 'package:sewamobil/shared/widgets/status_badge.dart';

void main() {
  group('CarRent Phase 1 Core Utilities Test', () {
    test('CurrencyFormatter correctly formats Rupiah amounts', () {
      expect(CurrencyFormatter.format(500000), contains('500.000'));
      expect(CurrencyFormatter.formatCompact(1500000), contains('1.5 jt'));
      expect(CurrencyFormatter.formatCompact(2000000000), contains('2.0 M'));
    });

    test('DateFormatter calculates rental duration correctly', () {
      final start = DateTime(2026, 10, 1, 10, 0);
      final end = DateTime(2026, 10, 4, 10, 0);
      expect(DateFormatter.calculateRentalDays(start, end), equals(3));
    });

    testWidgets('StatusBadge renders correct label and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge.available(),
          ),
        ),
      );

      expect(find.text('Tersedia'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('PriceText renders formatted currency and period', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceText(amount: 750000),
          ),
        ),
      );

      expect(find.byType(PriceText), findsOneWidget);
    });

    testWidgets('CarRentApp boots up and renders home navigation and branding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CarRentApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.appName), findsWidgets);
      expect(find.text(AppStrings.navHome), findsOneWidget);
    });
  });
}
