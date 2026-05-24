class ShopGameState {
  ShopGameState();

  int coins = 0;
  int currentCustomerIndex = 0;
  bool orderCompleted = false;
  final Set<String> ownedFurnitureIds = {};
  final Set<String> ownedStoreItemIds = {};

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
}
