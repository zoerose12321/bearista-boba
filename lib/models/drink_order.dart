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

  String get displayText => ingredients.join(' + ');
}
