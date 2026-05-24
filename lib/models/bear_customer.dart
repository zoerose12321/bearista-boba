import 'package:flutter/material.dart';

import 'custom_recipe.dart';
import 'drink_order.dart';
import 'player_character.dart';

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
    this.customRecipeName,
  });

  static const recipeBearId = 'recipe_bear';

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

  /// Display name for a custom recipe order (Recipe Bear only).
  final String? customRecipeName;

  bool get isRecipeBear => id == recipeBearId;

  String get orderDisplayText =>
      customRecipeName ?? order.displayText;

  String happyMessageWithReward(int coinReward) {
    return '$happyMessage +$coinReward coins';
  }

  factory BearCustomer.fromCustomRecipe(CustomRecipe recipe) {
    final ingredientHint = recipe.ingredients
        .map((ingredient) => ingredient.toLowerCase())
        .join(', ');

    return BearCustomer(
      id: recipeBearId,
      name: 'Recipe Bear',
      emoji: '✨🐻',
      order: recipe.order,
      customRecipeName: recipe.name,
      happyMessage: 'This recipe is paws-itively original! ✨',
      hintMessage: 'Recipe Bear wanted $ingredientHint.',
      furColor: const Color(0xFFE8C9F5),
      accentColor: const Color(0xFFB39DDB),
      muzzleColor: const Color(0xFFFFF5FC),
      accessory: BearAccessory.tinyHat,
      sizeScale: 0.95,
    );
  }
}
