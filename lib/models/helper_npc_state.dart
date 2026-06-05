/// Helper bear automation phases for local multiplayer (v0.1.53+).
enum HelperNpcPhase {
  inactive,
  idle,
  walkingToCustomer,
  takingOrder,
  makingDrink,
  servingDrink,
}

/// Tracks the NPC helper bear's café automation state.
class HelperNpcState {
  HelperNpcPhase phase = HelperNpcPhase.inactive;
  int? targetSlotIndex;
  double targetNormX = 0.44;
  double targetNormY = 0.64;
  String statusMessage = '';

  bool get isWorking =>
      phase == HelperNpcPhase.walkingToCustomer ||
      phase == HelperNpcPhase.takingOrder ||
      phase == HelperNpcPhase.makingDrink ||
      phase == HelperNpcPhase.servingDrink;

  bool isHandlingSlot(int slotIndex) {
    return targetSlotIndex == slotIndex && isWorking;
  }

  void reset() {
    phase = HelperNpcPhase.inactive;
    targetSlotIndex = null;
    statusMessage = '';
  }

  void activateIdle() {
    phase = HelperNpcPhase.idle;
    targetSlotIndex = null;
    statusMessage = 'Looking for orders…';
  }
}
