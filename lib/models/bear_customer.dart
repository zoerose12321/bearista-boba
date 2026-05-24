import 'package:flutter/material.dart';

import 'player_character.dart';
import 'drink_order.dart';

class BearCustomer {
  const BearCustomer({
    required this.id,
    required this.name,
    required this.emoji,
    required this.order,
    required this.happyMessage,
    required this.hintMessage,
    required this.furColor,
    required this.accentColor,
    this.muzzleColor = const Color(0xFFFFF0E0),
    this.accessory = BearAccessory.none,
    this.isPanda = false,
    this.sizeScale = 1.0,
  });

  final String id;
  final String name;
  final String emoji;
  final DrinkOrder order;
  final String happyMessage;
  final String hintMessage;
  final Color furColor;
  final Color accentColor;
  final Color muzzleColor;
  final BearAccessory accessory;
  final bool isPanda;
  final double sizeScale;

  String happyMessageWithReward(int coinReward) {
    return '$happyMessage +$coinReward coins';
  }
}
