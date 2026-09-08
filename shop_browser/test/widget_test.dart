// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shop_browser/main.dart';

void main() {
  testWidgets('shirt catalog displays products', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('THREADLINE'), findsOneWidget);
    expect(find.text('THE SHIRT EDIT'), findsOneWidget);
    expect(find.text('Studio Heavy Tee'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
  });

  testWidgets('product can be added, updated, and checked out', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Studio Heavy Tee'));
    await tester.pumpAndSettle();

    expect(find.text('Product details'), findsOneWidget);
    expect(find.text('A dependable layer made for repeat wear. Easy to style, comfortable through the day, and ready for whatever is next.'), findsOneWidget);
    expect(find.text('Add to bag'), findsOneWidget);

    await tester.tap(find.text('Add to bag'));
    await tester.pumpAndSettle();

    expect(find.text('Your bag'), findsOneWidget);
    expect(find.text(r'$32.00'), findsNWidgets(2));
    expect(find.text('Proceed to checkout'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();
    expect(find.text(r'$64.00'), findsNWidgets(2));

    await tester.tap(find.text('Proceed to checkout'));
    await tester.pumpAndSettle();
    expect(find.text('Order confirmed'), findsOneWidget);
    expect(find.text('Thanks for your order!'), findsOneWidget);
    expect(find.text(r'$64.00'), findsNWidgets(2));
  });

  testWidgets('checkout is unavailable with an empty cart', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();

    expect(find.text('Your bag is empty'), findsOneWidget);
    expect(find.text('Browse the shop'), findsOneWidget);
  });
}
