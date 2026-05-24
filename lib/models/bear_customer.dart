import 'drink_order.dart';

class BearCustomer {
  const BearCustomer({
    required this.id,
    required this.name,
    required this.emoji,
    required this.order,
  });

  final String id;
  final String name;
  final String emoji;
  final DrinkOrder order;
}
