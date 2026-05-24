class ShopGameState {
  ShopGameState();

  int coins = 0;
  int currentCustomerIndex = 0;
  bool orderCompleted = false;
  final Set<String> ownedFurnitureIds = {};

  void advanceCustomer(int customerCount) {
    currentCustomerIndex = (currentCustomerIndex + 1) % customerCount;
    orderCompleted = false;
  }
}
