import '../models/bear_customer.dart';
import '../models/drink_order.dart';

const starterCustomers = [
  BearCustomer(
    id: 'honey_bear',
    name: 'Honey Bear',
    emoji: '🍯',
    order: DrinkOrder(
      ingredients: ['Black Tea', 'Milk', 'Tapioca Pearls'],
    ),
    happyMessage: 'Perfect! Honey Bear loves it! 🍯✨ +10 coins',
    hintMessage: 'Honey Bear was hoping for black tea, milk, and tapioca pearls.',
  ),
  BearCustomer(
    id: 'panda_bear',
    name: 'Panda Bear',
    emoji: '🐼',
    order: DrinkOrder(
      ingredients: ['Green Tea', 'Milk', 'Boba Jelly'],
    ),
    happyMessage: 'Panda Bear is so happy! 🐼🍵 +10 coins',
    hintMessage: 'Panda Bear wanted green tea, milk, and boba jelly.',
  ),
  BearCustomer(
    id: 'baby_bear',
    name: 'Baby Bear',
    emoji: '🧸',
    order: DrinkOrder(
      ingredients: ['Strawberry Tea', 'Milk', 'Tapioca Pearls'],
    ),
    happyMessage: 'Baby Bear does a happy wiggle! 🧸🍓 +10 coins',
    hintMessage: 'Baby Bear wanted strawberry tea, milk, and tapioca pearls.',
  ),
  BearCustomer(
    id: 'polar_bear',
    name: 'Polar Bear',
    emoji: '🐻‍❄️',
    order: DrinkOrder(
      ingredients: ['Green Tea', 'Oat Milk', 'Boba Jelly'],
    ),
    happyMessage: 'Polar Bear gives an icy thumbs up! 🐻‍❄️❄️ +10 coins',
    hintMessage: 'Polar Bear wanted green tea, oat milk, and boba jelly.',
  ),
  BearCustomer(
    id: 'sleepy_bear',
    name: 'Sleepy Bear',
    emoji: '🌙🐻',
    order: DrinkOrder(
      ingredients: ['Black Tea', 'Oat Milk', 'Tapioca Pearls'],
    ),
    happyMessage: 'Sleepy Bear smiles softly. 🌙🐻 +10 coins',
    hintMessage: 'Sleepy Bear wanted black tea, oat milk, and tapioca pearls.',
  ),
];
