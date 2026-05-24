import '../data/starter_customers.dart';
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

  /// Special customer unlocked by the latest custom recipe.
  BearCustomer? recipeBear;

  bool ownsStoreItem(String id) => ownedStoreItemIds.contains(id);

  /// Returns true when the purchase succeeds.
  bool tryPurchaseStoreItem({required String id, required int cost}) {
    if (ownedStoreItemIds.contains(id) || coins < cost) {
      return false;
    }
    coins -= cost;
    ownedStoreItemIds.add(id);
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

  /// Starter bears plus any unlocked special customers.
  List<BearCustomer> get customerPool {
    final pool = List<BearCustomer>.from(starterCustomers);
    if (recipeBear != null) {
      pool.add(recipeBear!);
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
