enum StoreCategory {
  outfits('Outfits', 'Cozy aprons and bearista looks'),
  accessories('Accessories', 'Cute pins, bows, and glasses'),
  furniture('Furniture', 'Decor for your café'),
  ingredients('Ingredients', 'Special boba ingredients');

  const StoreCategory(this.title, this.description);

  final String title;
  final String description;
}

class StoreItem {
  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.emoji,
    required this.cost,
  });

  final String id;
  final String name;
  final String description;
  final StoreCategory category;
  final String emoji;
  final int cost;

  bool isOwned(Set<String> ownedIds) => ownedIds.contains(id);
}
