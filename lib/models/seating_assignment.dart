import 'dart:math';

import 'customer_visit_state.dart';

/// Picks random open seating spots for café customers.
class SeatingAssignment {
  SeatingAssignment._();

  static Random? testRandom;
  static final Random _random = Random();

  static Random get _rng => testRandom ?? _random;

  /// Returns up to [count] unique spots in random order.
  static List<CustomerSeatingSpot> pickUniqueSpots(int count) {
    final pool = List<CustomerSeatingSpot>.from(CustomerSeatingSpot.spots);
    pool.shuffle(_rng);
    return pool.take(count.clamp(0, pool.length)).toList();
  }

  /// Picks one open spot, or [fallback] when every spot is occupied.
  static CustomerSeatingSpot pickOpenSpot(
    Set<String> occupiedSeatIds, {
    CustomerSeatingSpot? fallback,
  }) {
    final open = CustomerSeatingSpot.spots
        .where((spot) => !occupiedSeatIds.contains(spot.id))
        .toList();
    if (open.isEmpty) {
      return fallback ?? CustomerSeatingSpot.spots.first;
    }
    return open[_rng.nextInt(open.length)];
  }
}
