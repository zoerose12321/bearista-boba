import 'bear_customer.dart';
import 'customer_visit_state.dart';
import 'shop_game_state.dart';

/// One bear customer currently visiting the café floor.
class ActiveCustomerVisit {
  ActiveCustomerVisit({
    required this.slotIndex,
    required this.customerId,
    required this.seat,
    this.phase = CustomerVisitPhase.waitingToEnter,
    this.orderCompleted = false,
    this.coinReward,
  });

  /// Animation slot (0–2) — not tied to a fixed seat location.
  final int slotIndex;

  /// Customer id from [ShopGameState.customerPool].
  String customerId;

  CustomerSeatingSpot seat;
  CustomerVisitPhase phase;
  bool orderCompleted;
  int? coinReward;

  BearCustomer customer(ShopGameState gameState) =>
      gameState.customerById(customerId);

  bool get isSeated => phase == CustomerVisitPhase.seatedReadyToOrder;

  bool get canTalk => isSeated && !orderCompleted;
}

/// Display data for one customer rendered in [CartoonShopScene].
class SceneCustomerDisplay {
  const SceneCustomerDisplay({
    required this.normX,
    required this.normY,
    required this.phase,
    required this.customer,
    required this.isSeated,
    required this.showSpeechPrompt,
  });

  final double normX;
  final double normY;
  final CustomerVisitPhase phase;
  final BearCustomer customer;
  final bool isSeated;
  final bool showSpeechPrompt;
}
