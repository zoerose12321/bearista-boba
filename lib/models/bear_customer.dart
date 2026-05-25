import 'package:flutter/material.dart';

import '../services/special_recipe_bear_factory.dart';
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
    this.cheekColor,
    this.accessory = BearAccessory.none,
    this.isPanda = false,
    this.sizeScale = 1.0,
    this.customRecipeName,
    this.specialBadgeEmoji,
  });

  static const recipeBearIdPrefix = 'recipe_bear_';

  static String recipeBearIdFor(String recipeId) => '$recipeBearIdPrefix$recipeId';

  final String id;
  final String name;
  final String emoji;
  final DrinkOrder order;
  final String happyMessage;
  final String hintMessage;
  final Color furColor;
  final Color accentColor;
  final Color muzzleColor;
  final Color? cheekColor;
  final BearAccessory accessory;
  final bool isPanda;
  final double sizeScale;

  /// Display name for a custom recipe order (special recipe bears only).
  final String? customRecipeName;

  /// Small ingredient badge shown on special recipe bears.
  final String? specialBadgeEmoji;

  bool get isRecipeBear => id.startsWith(recipeBearIdPrefix);

  String get orderDisplayText => customRecipeName ?? order.displayText;

  /// Shorter café label for long recipe-based bear names.
  String get cafeNameLabel {
    const maxLength = 16;
    if (name.length <= maxLength) {
      return name;
    }
    return '${name.substring(0, maxLength - 1)}…';
  }

  String happyMessageWithReward(int coinReward) {
    return '$happyMessage +$coinReward coins';
  }

  factory BearCustomer.fromCustomRecipe(CustomRecipe recipe) {
    return SpecialRecipeBearFactory.buildSpecialBear(recipe);
  }
}
