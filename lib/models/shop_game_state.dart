import '../data/starter_ingredients.dart';
import '../data/starter_customers.dart';
import '../data/store_items.dart';
import 'bear_customer.dart';
import 'custom_recipe.dart';

class ShopGameState {
  ShopGameState();

  int coins = 0;
  int currentCustomerIndex = 0;
  bool orderCompleted = false;
  final Set<String> ownedFurnitureIds = {};
  final Set<String> ownedStoreItemIds = {};
  final List<CustomRecipe> customRecipes = [];
  final Set<String> unlockedIngredientNames = StarterIngredients.initialUnlocked();

  /// Special customers unlocked by custom recipes, keyed by recipe id.
  final Map<String, BearCustomer> recipeBearsByRecipeId = {};

  bool ownsStoreItem(String id) => ownedStoreItemIds.contains(id);

  bool hasIngredient(String ingredientName) =>
      unlockedIngredientNames.contains(ingredientName);

  /// Returns true when the purchase succeeds.
  bool tryPurchaseStoreItem({required String id, required int cost}) {
    if (ownedStoreItemIds.contains(id) || coins < cost) {
      return false;
    }
    coins -= cost;
    ownedStoreItemIds.add(id);

    final item = storeItemById(id);
    if (item?.ingredientName != null) {
      unlockedIngredientNames.add(item!.ingredientName!);
    }

    return true;
  }

  void advanceCustomer(int customerCount) {
    currentCustomerIndex = (currentCustomerIndex + 1) % customerCount;
    orderCompleted = false;
  }

  /// Saves a custom recipe and unlocks/updates its special bear customer.
  void addCustomRecipe(CustomRecipe recipe) {
    customRecipes.add(recipe);
    recipeBearsByRecipeId[recipe.id] = BearCustomer.fromCustomRecipe(recipe);
  }

  bool _customerIsMakeable(BearCustomer customer) {
    return customer.order.usesOnlyUnlocked(unlockedIngredientNames);
  }

  /// Starter bears with makeable orders plus any unlocked special customers.
  List<BearCustomer> get customerPool {
    final pool = starterCustomers.where(_customerIsMakeable).toList();

    for (final bear in recipeBearsByRecipeId.values) {
      if (_customerIsMakeable(bear)) {
        pool.add(bear);
      }
    }

    if (pool.isEmpty) {
      return List<BearCustomer>.from(starterCustomers.take(3));
    }
    return pool;
  }

  BearCustomer customerById(String id) {
    for (final bear in recipeBearsByRecipeId.values) {
      if (bear.id == id) {
        return bear;
      }
    }
    return starterCustomers.firstWhere((customer) => customer.id == id);
  }
}
