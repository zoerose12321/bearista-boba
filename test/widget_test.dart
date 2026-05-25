import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bearista_boba/main.dart';
import 'package:bearista_boba/models/seating_assignment.dart';
import 'package:bearista_boba/services/coin_reward_service.dart';

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

Future<void> _tapDpad(
  WidgetTester tester, {
  int up = 0,
  int down = 0,
  int left = 0,
  int right = 0,
}) async {
  for (var i = 0; i < up; i++) {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded));
    await tester.pump(const Duration(milliseconds: 180));
  }
  for (var i = 0; i < down; i++) {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pump(const Duration(milliseconds: 180));
  }
  for (var i = 0; i < left; i++) {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
    await tester.pump(const Duration(milliseconds: 180));
  }
  for (var i = 0; i < right; i++) {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_right_rounded));
    await tester.pump(const Duration(milliseconds: 180));
  }
}

bool _canTalk(WidgetTester tester) {
  return find.widgetWithText(FilledButton, 'Talk').evaluate().isNotEmpty;
}

Future<bool> _tryOpenTalkForCustomer(
  WidgetTester tester,
  String customerName,
) async {
  if (!_canTalk(tester)) {
    return false;
  }

  await tester.tap(find.text('Talk'));
  await tester.pumpAndSettle();

  if (find.text(customerName).evaluate().isNotEmpty) {
    return true;
  }

  await tester.tap(find.byTooltip('Back'));
  await tester.pumpAndSettle();
  return false;
}

Future<void> _walkAndTalkToCustomer(
  WidgetTester tester,
  String customerName, {
  bool waitForSeat = true,
}) async {
  if (waitForSeat) {
    await _waitForCustomersSeated(tester);
  }

  if (await _tryOpenTalkForCustomer(tester, customerName)) {
    return;
  }

  final segments = <Future<void> Function()>[
    () => _tapDpad(tester, down: 4, right: 2),
    () => _tapDpad(tester, up: 5, left: 2),
    () => _tapDpad(tester, down: 3),
    () => _tapDpad(tester, down: 3),
    () => _tapDpad(tester, up: 6, right: 8),
    () => _tapDpad(tester, left: 6, down: 2),
    () => _tapDpad(tester, up: 4, right: 3),
    () => _tapDpad(tester, right: 6, up: 2),
    () => _tapDpad(tester, left: 4, up: 3),
  ];

  for (final segment in segments) {
    await segment();
    if (await _tryOpenTalkForCustomer(tester, customerName)) {
      return;
    }
  }

  fail('Could not reach $customerName for Talk');
}

Future<void> _walkAndTalkToAnyCustomer(
  WidgetTester tester, {
  bool waitForSeat = true,
}) async {
  const customerNames = [
    'Honey Bear',
    'Panda Bear',
    'Baby Bear',
    'Polar Bear',
    'Sleepy Bear',
  ];

  if (waitForSeat) {
    await _waitForCustomersSeated(tester);
  }

  for (var attempt = 0; attempt < 2; attempt++) {
    if (attempt > 0) {
      await _tapDpad(tester, down: 5, right: 1);
    }

    for (final name in customerNames) {
      if (await _tryOpenTalkForCustomer(tester, name)) {
        return;
      }
    }

    final segments = <Future<void> Function()>[
      () => _tapDpad(tester, down: 4, right: 2),
      () => _tapDpad(tester, up: 5, left: 2),
      () => _tapDpad(tester, down: 3),
      () => _tapDpad(tester, down: 3),
      () => _tapDpad(tester, up: 6, right: 8),
      () => _tapDpad(tester, left: 6, down: 2),
      () => _tapDpad(tester, up: 4, right: 3),
      () => _tapDpad(tester, right: 6, up: 2),
      () => _tapDpad(tester, left: 4, up: 3),
    ];

    for (final segment in segments) {
      await segment();
      for (final name in customerNames) {
        if (await _tryOpenTalkForCustomer(tester, name)) {
          return;
        }
      }
    }
  }

  fail('Could not reach any customer for Talk');
}

Future<void> _serveVisibleCustomerOrder(WidgetTester tester) async {
  const orders = {
    'Honey Bear': ['Black Tea', 'Milk', 'Tapioca Pearls'],
    'Panda Bear': ['Green Tea', 'Milk', 'Boba Jelly'],
    'Baby Bear': ['Black Tea', 'Milk', 'Boba Jelly'],
    'Polar Bear': ['Green Tea', 'Milk', 'Tapioca Pearls'],
    'Sleepy Bear': ['Black Tea', 'Milk', 'Tapioca Pearls'],
  };

  for (final entry in orders.entries) {
    if (find.text(entry.key).evaluate().isEmpty) {
      continue;
    }
    for (final ingredient in entry.value) {
      await tester.tap(find.text(ingredient));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Serve Drink'));
    await tester.tap(find.text('Serve Drink'));
    await tester.pump();
    return;
  }

  fail('No known customer order page is open');
}

Future<void> _openBearistaShopForCustomer(
  WidgetTester tester,
  String customerName,
) async {
  await _enterShop(tester);
  await _walkAndTalkToCustomer(tester, customerName);
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

Future<void> _walkToMinigames(WidgetTester tester) async {
  await _tapDpad(tester, up: 5, right: 2);
}

Future<void> _openMinigamesHub(WidgetTester tester) async {
  await _enterShop(tester);
  await _walkToMinigames(tester);
  await tester.tap(find.byKey(const Key('play_minigames')));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SeatingAssignment.testRandom = Random(42);
  });

  tearDown(() {
    SeatingAssignment.testRandom = null;
    CoinRewardService.rollRewardOverride = null;
  });

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

    await _walkAndTalkToCustomer(tester, 'Honey Bear');

    expect(find.text('Bearista Shop'), findsOneWidget);
    expect(find.text('Serve Drink'), findsOneWidget);
  });

  testWidgets('Correct drink awards coins once per order', (WidgetTester tester) async {
    CoinRewardService.rollRewardOverride = () => 12;

    await tester.pumpWidget(const BearistaBobaApp());
    await _openBearistaShopForCustomer(tester, 'Honey Bear');

    expect(find.text('🪙 0'), findsOneWidget);

    await _serveHoneyBearOrder(tester);

    expect(find.text('🪙 12'), findsOneWidget);
    expect(find.textContaining('Perfect! Honey Bear loves it!'), findsOneWidget);
    expect(find.textContaining('+12 coins'), findsOneWidget);
    expect(find.text('Back to Shop'), findsOneWidget);

    await tester.ensureVisible(find.text('Serve Drink'));
    await tester.tap(find.text('Serve Drink'));
    await tester.pump();

    expect(find.text('🪙 12'), findsOneWidget);
  });

  testWidgets('Talk opens selected customer order', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());
    await _enterShop(tester);
    await _walkAndTalkToCustomer(tester, 'Panda Bear');

    expect(find.text('Panda Bear'), findsOneWidget);
    expect(find.text('Green Tea + Milk + Boba Jelly'), findsOneWidget);
  });

  testWidgets('Wrong drink shows customer hint', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());
    await _openBearistaShopForCustomer(tester, 'Honey Bear');

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
    CoinRewardService.rollRewardOverride = () => 12;

    await tester.pumpWidget(const BearistaBobaApp());
    await _openBearistaShopForCustomer(tester, 'Honey Bear');

    await _serveHoneyBearOrder(tester);
    await tester.ensureVisible(find.text('Back to Shop'));
    await tester.tap(find.text('Back to Shop'));
    await tester.pumpAndSettle();

    await _walkAndTalkToAnyCustomer(tester, waitForSeat: false);
    await _serveVisibleCustomerOrder(tester);

    expect(find.text('🪙 24'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shop Upgrades'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buy').first);
    await tester.pump();

    expect(find.text('🪙 4 coins'), findsOneWidget);
    expect(find.textContaining('Cozy Table is now in your shop!'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('🪵'), findsOneWidget);
  });

  testWidgets('Minigames hub opens from café game corner', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());
    await _openMinigamesHub(tester);

    expect(find.text('Boba Games'), findsOneWidget);
    expect(find.text('Boba Catch'), findsOneWidget);
    expect(find.text('Boba Stack'), findsOneWidget);
    expect(find.text('Tea Time Dash'), findsOneWidget);
    expect(find.textContaining('Create your own boba recipe'), findsOneWidget);
    expect(find.text('Play'), findsNWidgets(3));
    expect(find.text('Coming later'), findsNothing);
  });

  testWidgets('Boba Catch awards capped coins once per round', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());
    await _openMinigamesHub(tester);

    await tester.tap(find.byKey(const Key('minigame_play_boba_catch')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Game'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 21));

    expect(find.textContaining('Time\'s up!'), findsOneWidget);
    expect(find.textContaining('Score:'), findsWidgets);
    expect(find.textContaining('No coins this round'), findsOneWidget);

    await tester.tap(find.byKey(const Key('boba_catch_play_again')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('boba_catch_left')), findsOneWidget);
    expect(find.textContaining('Score: 0'), findsWidgets);
  });

  testWidgets('Boba Stack jump game finishes round', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());
    await _openMinigamesHub(tester);

    await tester.ensureVisible(find.byKey(const Key('minigame_play_boba_stack')));
    await tester.tap(find.byKey(const Key('minigame_play_boba_stack')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Game'));
    await tester.pump(const Duration(milliseconds: 500));

    for (var i = 0; i < 50; i++) {
      await tester.tap(find.byKey(const Key('boba_stack_jump')));
      await tester.pump(const Duration(milliseconds: 90));
    }

    await tester.pump(const Duration(seconds: 21));

    expect(find.textContaining('Cups stacked:'), findsOneWidget);
    expect(find.byKey(const Key('boba_stack_play_again')), findsOneWidget);
  });

  testWidgets('Tea Time Dash creates recipe and unlocks special bear', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());
    await _openMinigamesHub(tester);

    await tester.ensureVisible(find.byKey(const Key('minigame_play_tea_time_dash')));
    await tester.tap(find.byKey(const Key('minigame_play_tea_time_dash')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Create your own boba recipe'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('recipe_tea_Black Tea')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('recipe_milk_Milk')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('recipe_topping_Tapioca Pearls')));
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('recipe_name_field')));
    await tester.enterText(
      find.byKey(const Key('recipe_name_field')),
      'Honey Cloud Boba',
    );
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('create_recipe_button')));
    await tester.tap(find.byKey(const Key('create_recipe_button')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Recipe Created!'), findsOneWidget);
    expect(find.text('Honey Cloud Boba'), findsOneWidget);
    expect(find.textContaining('Honey Cloud Bear unlocked!'), findsOneWidget);
    expect(
      find.textContaining('Black Tea + Milk + Tapioca Pearls'),
      findsOneWidget,
    );
  });
}
