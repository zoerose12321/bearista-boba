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

  /// Special customer unlocked by the latest custom recipe.
  BearCustomer? recipeBear;

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

  /// Saves a custom recipe and unlocks/updates Recipe Bear.
  void addCustomRecipe(CustomRecipe recipe) {
    customRecipes.add(recipe);
    recipeBear = BearCustomer.fromCustomRecipe(recipe);
  }

  bool _customerIsMakeable(BearCustomer customer) {
    return customer.order.usesOnlyUnlocked(unlockedIngredientNames);
  }

  /// Starter bears with makeable orders plus any unlocked special customers.
  List<BearCustomer> get customerPool {
    final pool = starterCustomers
        .where(_customerIsMakeable)
        .toList();
    if (recipeBear != null && _customerIsMakeable(recipeBear!)) {
      pool.add(recipeBear!);
    }
    if (pool.isEmpty) {
      return List<BearCustomer>.from(starterCustomers.take(3));
    }
    return pool;
  }

  BearCustomer customerById(String id) {
    if (id == BearCustomer.recipeBearId && recipeBear != null) {
      return recipeBear!;
    }
    return starterCustomers.firstWhere((customer) => customer.id == id);
  }
}
