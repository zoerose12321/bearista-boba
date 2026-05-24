import 'package:flutter/material.dart';

import '../models/bear_customer.dart';
import '../models/drink_order.dart';
import '../models/player_character.dart';

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
    furColor: Color(0xFFE8B86D),
    accentColor: Color(0xFFE8A598),
    accessory: BearAccessory.flower,
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
    furColor: Color(0xFFF7F7F7),
    accentColor: Color(0xFFB8D4A8),
    isPanda: true,
    accessory: BearAccessory.bow,
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
    furColor: Color(0xFFD4A574),
    accentColor: Color(0xFFF5A8C8),
    muzzleColor: Color(0xFFFFF5EB),
    accessory: BearAccessory.bow,
    sizeScale: 0.82,
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
    furColor: Color(0xFFF5F8FF),
    accentColor: Color(0xFFA8D4F0),
    muzzleColor: Color(0xFFEEF4FF),
    accessory: BearAccessory.tinyHat,
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
    furColor: Color(0xFFC9C0D8),
    accentColor: Color(0xFFC9B8E8),
    muzzleColor: Color(0xFFF0ECF8),
    accessory: BearAccessory.tinyHat,
  ),
];
