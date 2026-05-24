import '../models/store_item.dart';

const storeItems = [
  // Outfits
  StoreItem(
    id: 'pink_apron',
    name: 'Pink Apron',
    description: 'A sweet pink apron for sunny shift days.',
    category: StoreCategory.outfits,
    emoji: '🎀',
    cost: 20,
  ),
  StoreItem(
    id: 'mint_apron',
    name: 'Mint Apron',
    description: 'Fresh mint green for a calm bearista vibe.',
    category: StoreCategory.outfits,
    emoji: '🌿',
    cost: 25,
  ),
  StoreItem(
    id: 'honey_apron',
    name: 'Honey Apron',
    description: 'Golden honey tones for a cozy look.',
    category: StoreCategory.outfits,
    emoji: '🍯',
    cost: 30,
  ),

  // Accessories
  StoreItem(
    id: 'tiny_bow',
    name: 'Tiny Bow',
    description: 'A little bow to brighten any outfit.',
    category: StoreCategory.accessories,
    emoji: '🎀',
    cost: 15,
  ),
  StoreItem(
    id: 'round_glasses',
    name: 'Round Glasses',
    description: 'Scholarly specs for recipe reading.',
    category: StoreCategory.accessories,
    emoji: '👓',
    cost: 20,
  ),
  StoreItem(
    id: 'flower_pin',
    name: 'Flower Pin',
    description: 'A pastel flower pin for your apron.',
    category: StoreCategory.accessories,
    emoji: '🌸',
    cost: 25,
  ),

  // Furniture
  StoreItem(
    id: 'cozy_lamp',
    name: 'Cozy Lamp',
    description: 'Soft light for late-night boba prep.',
    category: StoreCategory.furniture,
    emoji: '🛋️',
    cost: 30,
  ),
  StoreItem(
    id: 'wall_plant',
    name: 'Wall Plant',
    description: 'A leafy friend for your café wall.',
    category: StoreCategory.furniture,
    emoji: '🪴',
    cost: 35,
  ),
  StoreItem(
    id: 'dessert_display',
    name: 'Dessert Display',
    description: 'Show off cute treats beside the counter.',
    category: StoreCategory.furniture,
    emoji: '🍰',
    cost: 45,
  ),

  // Ingredients
  StoreItem(
    id: 'matcha_powder',
    name: 'Matcha Powder',
    description: 'Premium matcha for future drink recipes.',
    category: StoreCategory.ingredients,
    emoji: '🍵',
    cost: 20,
  ),
  StoreItem(
    id: 'strawberry_syrup',
    name: 'Strawberry Syrup',
    description: 'Sweet strawberry syrup for fruity drinks.',
    category: StoreCategory.ingredients,
    emoji: '🍓',
    cost: 25,
  ),
  StoreItem(
    id: 'honey_drizzle',
    name: 'Honey Drizzle',
    description: 'Golden honey drizzle for special orders.',
    category: StoreCategory.ingredients,
    emoji: '🍯',
    cost: 30,
  ),
];

List<StoreItem> storeItemsForCategory(StoreCategory category) {
  return storeItems.where((item) => item.category == category).toList();
}

StoreCategory? storeCategoryFromTitle(String title) {
  for (final category in StoreCategory.values) {
    if (category.title == title) {
      return category;
    }
  }
  return null;
}
