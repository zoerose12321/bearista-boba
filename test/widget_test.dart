import 'package:flutter_test/flutter_test.dart';

import 'package:bearista_boba/main.dart';

void main() {
  testWidgets('Home page shows title and start button', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());

    expect(find.text('Bearista Boba'), findsOneWidget);
    expect(find.text('A cozy boba shop game'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('Navigation flow reaches shop page', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Your Bearista'), findsOneWidget);
    expect(find.text('Sunny'), findsOneWidget);

    await tester.tap(find.text('Sunny'));
    await tester.pumpAndSettle();

    expect(find.text('Bearista Shop'), findsOneWidget);
    expect(find.text('Honey Bear'), findsOneWidget);
    expect(find.text('Serve Drink'), findsOneWidget);
  });

  testWidgets('Correct drink awards coins', (WidgetTester tester) async {
    await tester.pumpWidget(const BearistaBobaApp());

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mochi'));
    await tester.pumpAndSettle();

    expect(find.text('🪙 0'), findsOneWidget);

    for (final ingredient in ['Black Tea', 'Milk', 'Tapioca Pearls']) {
      await tester.tap(find.text(ingredient));
      await tester.pump();
    }

    await tester.ensureVisible(find.text('Serve Drink'));
    await tester.tap(find.text('Serve Drink'));
    await tester.pump();

    expect(find.text('🪙 10'), findsOneWidget);
    expect(find.textContaining('Perfect!'), findsOneWidget);
  });
}
