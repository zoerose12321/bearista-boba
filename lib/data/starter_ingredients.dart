/// Ingredient unlock lists for Bearista Boba.
class StarterIngredients {
  StarterIngredients._();

  static const starter = [
    'Black Tea',
    'Green Tea',
    'Milk',
    'Tapioca Pearls',
    'Boba Jelly',
  ];

  static const locked = [
    'Strawberry Tea',
    'Matcha Tea',
    'Oat Milk',
    'Coconut Milk',
    'Strawberry Jelly',
    'Honey Drizzle',
    'Vanilla',
    'Lavender',
    'Brown Sugar',
  ];

  static const all = [...starter, ...locked];

  static Set<String> initialUnlocked() => Set<String>.from(starter);

  static bool isStarter(String ingredientName) => starter.contains(ingredientName);

  static List<String> unlockedFrom(Iterable<String> unlocked) {
    return all.where(unlocked.contains).toList();
  }

  static List<String> filterUnlocked(
    Iterable<String> options,
    Set<String> unlocked,
  ) {
    return options.where(unlocked.contains).toList();
  }
}
