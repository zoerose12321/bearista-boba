import 'package:flutter/material.dart';

import '../models/bear_customer.dart';
import '../models/custom_recipe.dart';
import '../models/player_character.dart';

/// Builds special recipe bear customers from custom recipes.
class SpecialRecipeBearFactory {
  const SpecialRecipeBearFactory._();

  /// If [recipeName] already ends with "Bear", use as-is; otherwise replace the
  /// last word with "Bear" (or append " Bear" for single-word names).
  static String bearNameFromRecipeName(String recipeName) {
    final trimmed = recipeName.trim();
    if (trimmed.isEmpty) {
      return 'Recipe Bear';
    }
    if (trimmed.toLowerCase().endsWith('bear')) {
      return trimmed;
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return '$trimmed Bear';
    }
    parts[parts.length - 1] = 'Bear';
    return parts.join(' ');
  }

  static BearCustomer buildSpecialBear(CustomRecipe recipe) {
    final bearName = bearNameFromRecipeName(recipe.name);
    final style = _styleForIngredients(recipe.ingredients);
    final ingredientHint = recipe.ingredients
        .map((ingredient) => ingredient.toLowerCase())
        .join(', ');

    return BearCustomer(
      id: BearCustomer.recipeBearIdFor(recipe.id),
      name: bearName,
      emoji: style.specialBadgeEmoji,
      order: recipe.order,
      customRecipeName: recipe.name,
      happyMessage: '$bearName loves your original recipe! ✨',
      hintMessage: '$bearName wanted $ingredientHint.',
      furColor: style.furColor,
      accentColor: style.accentColor,
      muzzleColor: style.muzzleColor,
      cheekColor: style.cheekColor,
      accessory: style.accessory,
      specialBadgeEmoji: style.specialBadgeEmoji,
      sizeScale: 0.95,
    );
  }

  static _SpecialBearStyle _styleForIngredients(List<String> ingredients) {
    for (final rule in _stylePriority) {
      if (ingredients.any(rule.matches)) {
        return rule.style;
      }
    }
    return _defaultStyle;
  }
}

class _SpecialBearStyle {
  const _SpecialBearStyle({
    required this.furColor,
    required this.accentColor,
    required this.muzzleColor,
    required this.cheekColor,
    required this.specialBadgeEmoji,
    this.accessory = BearAccessory.tinyHat,
  });

  final Color furColor;
  final Color accentColor;
  final Color muzzleColor;
  final Color cheekColor;
  final String specialBadgeEmoji;
  final BearAccessory accessory;
}

class _IngredientStyleRule {
  const _IngredientStyleRule({
    required this.matches,
    required this.style,
  });

  final bool Function(String ingredient) matches;
  final _SpecialBearStyle style;
}

const _defaultStyle = _SpecialBearStyle(
  furColor: Color(0xFFE8C9F5),
  accentColor: Color(0xFFB39DDB),
  muzzleColor: Color(0xFFFFF5FC),
  cheekColor: Color(0xFFD1A8E8),
  specialBadgeEmoji: '✨',
);

final _stylePriority = <_IngredientStyleRule>[
  _IngredientStyleRule(
    matches: (ingredient) => ingredient == 'Lavender',
    style: _SpecialBearStyle(
      furColor: Color(0xFFE8C9F5),
      accentColor: Color(0xFFB39DDB),
      muzzleColor: Color(0xFFFFF5FC),
      cheekColor: Color(0xFFD1A8E8),
      specialBadgeEmoji: '💜',
    ),
  ),
  _IngredientStyleRule(
    matches: (ingredient) =>
        ingredient == 'Strawberry Tea' || ingredient == 'Strawberry Jelly',
    style: _SpecialBearStyle(
      furColor: Color(0xFFF8C4D0),
      accentColor: Color(0xFFE8788A),
      muzzleColor: Color(0xFFFFF0F3),
      cheekColor: Color(0xFFF5A8C8),
      specialBadgeEmoji: '🍓',
      accessory: BearAccessory.flower,
    ),
  ),
  _IngredientStyleRule(
    matches: (ingredient) => ingredient == 'Matcha Tea',
    style: _SpecialBearStyle(
      furColor: Color(0xFFC8E6C9),
      accentColor: Color(0xFF7CB342),
      muzzleColor: Color(0xFFF1F8E9),
      cheekColor: Color(0xFFA5D6A7),
      specialBadgeEmoji: '🍵',
    ),
  ),
  _IngredientStyleRule(
    matches: (ingredient) => ingredient == 'Honey Drizzle',
    style: _SpecialBearStyle(
      furColor: Color(0xFFF5DFA8),
      accentColor: Color(0xFFE8B86D),
      muzzleColor: Color(0xFFFFF8E7),
      cheekColor: Color(0xFFF5D6A8),
      specialBadgeEmoji: '🍯',
      accessory: BearAccessory.bow,
    ),
  ),
  _IngredientStyleRule(
    matches: (ingredient) => ingredient == 'Brown Sugar',
    style: _SpecialBearStyle(
      furColor: Color(0xFFD4A574),
      accentColor: Color(0xFF8B5E3C),
      muzzleColor: Color(0xFFFFF0E0),
      cheekColor: Color(0xFFE8B86D),
      specialBadgeEmoji: '🧋',
    ),
  ),
  _IngredientStyleRule(
    matches: (ingredient) => ingredient == 'Coconut Milk',
    style: _SpecialBearStyle(
      furColor: Color(0xFFFFF8F0),
      accentColor: Color(0xFFE8DCC8),
      muzzleColor: Color(0xFFFFFBF5),
      cheekColor: Color(0xFFF5E6C8),
      specialBadgeEmoji: '🥥',
    ),
  ),
  _IngredientStyleRule(
    matches: (ingredient) => ingredient == 'Oat Milk',
    style: _SpecialBearStyle(
      furColor: Color(0xFFE8DCC4),
      accentColor: Color(0xFFC4A882),
      muzzleColor: Color(0xFFFFF5E8),
      cheekColor: Color(0xFFD4C4A8),
      specialBadgeEmoji: '🌾',
    ),
  ),
  _IngredientStyleRule(
    matches: (ingredient) => ingredient == 'Vanilla',
    style: _SpecialBearStyle(
      furColor: Color(0xFFFFF5DC),
      accentColor: Color(0xFFF5D6A8),
      muzzleColor: Color(0xFFFFFAF0),
      cheekColor: Color(0xFFF5E6C8),
      specialBadgeEmoji: '🌼',
    ),
  ),
  _IngredientStyleRule(
    matches: (ingredient) =>
        ingredient == 'Boba Jelly' || ingredient == 'Tapioca Pearls',
    style: _SpecialBearStyle(
      furColor: Color(0xFFE8C9A8),
      accentColor: Color(0xFFA67C52),
      muzzleColor: Color(0xFFFFF0E0),
      cheekColor: Color(0xFFD4A574),
      specialBadgeEmoji: '🧋',
    ),
  ),
];
