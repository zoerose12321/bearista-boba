import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bearista_boba/main.dart';

Future<void> _enterShop(
  WidgetTester tester, {
  String? customName,
}) async {
  await tester.tap(find.text('Start'));
  await tester.pumpAndSettle();

  if (customName != null) {
    await tester.tap(find.byKey(const Key('shop_player_tap')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), customName);
    await tester.pump();

    await tester.tap(find.byKey(const Key('save_character_changes')));
    await tester.pumpAndSettle();
  }
}

Future<void> _waitForCustomersSeated(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 2800));
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _walkToHoneyBear(WidgetTester tester) async {
  await _waitForCustomersSeated(tester);

  // Honey Bear sits at table seat 1 (~0.24, 0.30).
  for (var i = 0; i < 5; i++) {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded));
    await tester.pump(const Duration(milliseconds: 180));
  }
  for (var i = 0; i < 2; i++) {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
    await tester.pump(const Duration(milliseconds: 180));
  }
}

Future<void> _walkToPandaBear(WidgetTester tester) async {
  await _waitForCustomersSeated(tester);

  // Panda Bear sits at table seat 2 (~0.24, 0.50) from default spawn.
  for (var i = 0; i < 2; i++) {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded));
    await tester.pump(const Duration(milliseconds: 180));
  }
  for (var i = 0; i < 3; i++) {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
    await tester.pump(const Duration(milliseconds: 180));
  }
}

Future<void> _walkToPandaFromTableOne(WidgetTester tester) async {
  // After visiting Honey Bear at table 1, walk down to Panda at table 2.
  for (var i = 0; i < 3; i++) {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pump(const Duration(milliseconds: 180));
  }
}

Future<void> _openBearistaShopForHoney(WidgetTester tester) async {
  await _enterShop(tester);
  await _walkToHoneyBear(tester);
  await tester.tap(find.text('Talk'));
  await tester.pumpAndSettle();
}

Future<void> _serveHoneyBearOrder(WidgetTester tester) async {
  for (final ingredient in ['Black Tea', 'Milk', 'Tapioca Pearls']) {
    await tester.tap(find.text(ingredient));
    await tester.pump();
  }

  await tester.ensureVisible(find.text('Serve Drink'));
  await tester.tap(find.text('Serve Drink'));
  await tester.pump();
}

void main() {
  testWidgets('Home page shows title and start button', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());

    expect(find.text('Bearista Boba'), findsOneWidget);
    expect(find.text('Run your cozy boba café'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('Navigation flow reaches shop world and bearista shop', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());

    await _enterShop(tester, customName: 'Sunny');

    expect(find.text('Sunny\'s Shop'), findsOneWidget);
    expect(find.text('Talk'), findsOneWidget);
    expect(find.text('Shop Upgrades'), findsOneWidget);
    expect(find.text('Honey Bear'), findsOneWidget);
    expect(find.text('Panda Bear'), findsOneWidget);
    expect(find.text('Baby Bear'), findsOneWidget);

    await _walkToHoneyBear(tester);
    await tester.tap(find.text('Talk'));
    await tester.pumpAndSettle();

    expect(find.text('Bearista Shop'), findsOneWidget);
    expect(find.text('Serve Drink'), findsOneWidget);
  });

  testWidgets('Correct drink awards coins once per order', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());
    await _openBearistaShopForHoney(tester);

    expect(find.text('🪙 0'), findsOneWidget);

    await _serveHoneyBearOrder(tester);

    expect(find.text('🪙 10'), findsOneWidget);
    expect(find.textContaining('Perfect! Honey Bear loves it!'), findsOneWidget);
    expect(find.text('Back to Shop'), findsOneWidget);

    await tester.ensureVisible(find.text('Serve Drink'));
    await tester.tap(find.text('Serve Drink'));
    await tester.pump();

    expect(find.text('🪙 10'), findsOneWidget);
  });

  testWidgets('Talk opens selected customer order', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());
    await _enterShop(tester);
    await _walkToPandaBear(tester);
    await tester.tap(find.text('Talk'));
    await tester.pumpAndSettle();

    expect(find.text('Panda Bear'), findsOneWidget);
    expect(find.text('Green Tea + Milk + Boba Jelly'), findsOneWidget);
  });

  testWidgets('Wrong drink shows customer hint', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());
    await _openBearistaShopForHoney(tester);

    await tester.tap(find.text('Green Tea'));
    await tester.pump();

    await tester.ensureVisible(find.text('Serve Drink'));
    await tester.tap(find.text('Serve Drink'));
    await tester.pump();

    expect(
      find.text('Honey Bear was hoping for black tea, milk, and tapioca pearls.'),
      findsOneWidget,
    );
    expect(find.text('🪙 0'), findsOneWidget);
  });

  testWidgets('Furniture can be bought with enough coins', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());
    await _openBearistaShopForHoney(tester);

    await _serveHoneyBearOrder(tester);
    await tester.ensureVisible(find.text('Back to Shop'));
    await tester.tap(find.text('Back to Shop'));
    await tester.pumpAndSettle();

    await _walkToPandaFromTableOne(tester);
    await tester.tap(find.text('Talk'));
    await tester.pumpAndSettle();

    for (final ingredient in ['Green Tea', 'Milk', 'Boba Jelly']) {
      await tester.tap(find.text(ingredient));
      await tester.pump();
    }

    await tester.ensureVisible(find.text('Serve Drink'));
    await tester.tap(find.text('Serve Drink'));
    await tester.pump();

    expect(find.text('🪙 20'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shop Upgrades'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buy').first);
    await tester.pump();

    expect(find.text('🪙 0 coins'), findsOneWidget);
    expect(find.textContaining('Cozy Table is now in your shop!'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('🪵'), findsOneWidget);
  });
}
