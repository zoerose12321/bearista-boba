/// Where a visiting customer can sit in the café scene.
enum SeatingSpotType {
  table,
  couch,
}

/// Normalized seating location within the shop floor (0–1).
class CustomerSeatingSpot {
  const CustomerSeatingSpot({
    required this.id,
    required this.label,
    required this.type,
    required this.normX,
    required this.normY,
  });

  final String id;
  final String label;
  final SeatingSpotType type;
  final double normX;
  final double normY;

  /// Entry near the bottom-left door.
  static const entryNormX = 0.13;
  static const entryNormY = 0.86;

  /// Normalized bounds for the player entry/door trigger.
  static const entryTriggerMinX = 0.09;
  static const entryTriggerMaxX = 0.24;
  static const entryTriggerMinY = 0.72;
  static const entryTriggerMaxY = 0.84;

  static bool isPlayerOnEntry(double normX, double normY) {
    return normX >= entryTriggerMinX &&
        normX <= entryTriggerMaxX &&
        normY >= entryTriggerMinY &&
        normY <= entryTriggerMaxY;
  }

  /// Mid-aisle waypoint between entry and seats.
  static const midAisleNormX = 0.30;
  static const midAisleNormY = 0.64;

  static const tableSeatOne = CustomerSeatingSpot(
    id: 'table_seat_1',
    label: 'Table seat 1',
    type: SeatingSpotType.table,
    normX: 0.24,
    normY: 0.30,
  );

  static const tableSeatTwo = CustomerSeatingSpot(
    id: 'table_seat_2',
    label: 'Table seat 2',
    type: SeatingSpotType.table,
    normX: 0.24,
    normY: 0.50,
  );

  static const couchSeat = CustomerSeatingSpot(
    id: 'couch_seat',
    label: 'Couch seat',
    type: SeatingSpotType.couch,
    normX: 0.74,
    normY: 0.58,
  );

  static const spots = [tableSeatOne, tableSeatTwo, couchSeat];

  static CustomerSeatingSpot forSlotIndex(int slotIndex) {
    return spots[slotIndex % spots.length];
  }

  static CustomerSeatingSpot forCustomerIndex(int index) {
    return spots[index % spots.length];
  }
}

/// Current phase of a customer visit in ShopWorldPage.
enum CustomerVisitPhase {
  waitingToEnter,
  entering,
  walkingToSeat,
  seatedReadyToOrder,
}
