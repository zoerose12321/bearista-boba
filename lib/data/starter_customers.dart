import '../models/bear_customer.dart';
import '../models/drink_order.dart';

const honeyBearOrder = DrinkOrder(
  ingredients: ['Black Tea', 'Milk', 'Tapioca Pearls'],
);

const starterCustomers = [
  BearCustomer(
    id: 'honey_bear',
    name: 'Honey Bear',
    emoji: '🍯',
    order: honeyBearOrder,
  ),
];
