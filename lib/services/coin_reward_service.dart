import 'dart:math';

/// Rolls coin rewards for correctly served customer orders.
class CoinRewardService {
  CoinRewardService._();

  static const minReward = 8;
  static const maxReward = 15;

  static final Random _random = Random();

  /// Optional override for widget tests.
  static int Function()? rollRewardOverride;

  static int rollReward() {
    if (rollRewardOverride != null) {
      return rollRewardOverride!();
    }
    return minReward + _random.nextInt(maxReward - minReward + 1);
  }
}
