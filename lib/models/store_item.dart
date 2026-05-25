enum StoreCategory {
  outfits('Outfits', 'Cozy aprons and bearista looks'),
  accessories('Accessories', 'Cute pins, bows, and glasses'),
  furniture('Furniture', 'Decor for your café'),
  ingredients('Ingredients', 'Special boba ingredients');

  const StoreCategory(this.title, this.description);

  final String title;
  final String description;
}

enum StoreWearableKind {
  none,
  outfit,
  accessory,
}

class StoreItem {
  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.emoji,
    required this.cost,
    this.wearableKind = StoreWearableKind.none,
    this.apronColor,
    this.accessoryKind,
    this.ingredientName,
  });

  final String id;
  final String name;
  final String description;
  final StoreCategory category;
  final String emoji;
  final int cost;
  final StoreWearableKind wearableKind;

  /// Apron tint for outfit items.
  final int? apronColor;

  /// Accessory id string matching [PlayerCharacter] store accessory ids.
  final String? accessoryKind;

  /// Ingredient display name unlocked when this item is purchased.
  final String? ingredientName;

  bool get isWearable => wearableKind != StoreWearableKind.none;
  bool get isOutfit => wearableKind == StoreWearableKind.outfit;
  bool get isAccessory => wearableKind == StoreWearableKind.accessory;
  bool get isIngredientUnlock =>
      category == StoreCategory.ingredients && ingredientName != null;

  bool isOwned(Set<String> ownedIds) => ownedIds.contains(id);
}
