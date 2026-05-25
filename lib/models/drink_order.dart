class DrinkOrder {
  const DrinkOrder({required this.ingredients});

  final List<String> ingredients;

  bool matches(DrinkOrder other) {
    if (ingredients.length != other.ingredients.length) {
      return false;
    }

    final sortedA = List<String>.from(ingredients)..sort();
    final sortedB = List<String>.from(other.ingredients)..sort();
    for (var i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) {
        return false;
      }
    }
    return true;
  }

  /// True when every ingredient in this order is unlocked.
  bool usesOnlyUnlocked(Set<String> unlockedIngredientNames) {
    return ingredients.every(unlockedIngredientNames.contains);
  }

  String get displayText => ingredients.join(' + ');
}
