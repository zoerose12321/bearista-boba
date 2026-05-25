/// Outcome of a completed minigame round.
class MinigameResult {
  const MinigameResult({
    required this.score,
    required this.coinsEarned,
  });

  final int score;
  final int coinsEarned;

  static const maxCoinReward = 15;

  /// Boba Catch: 1 coin per catch, capped at [maxCoinReward].
  static int coinsForBobaCatchScore(int score, {int maxCoinReward = maxCoinReward}) {
    if (score <= 0) {
      return 0;
    }
    return score.clamp(0, maxCoinReward);
  }

  /// Boba Stack: 1 coin per 2 cups stacked, minimum 1 if any stacked.
  static int coinsForBobaStackScore(int cupsStacked, {int maxCoinReward = maxCoinReward}) {
    if (cupsStacked <= 0) {
      return 0;
    }
    final base = cupsStacked ~/ 2;
    final earned = base < 1 ? 1 : base;
    return earned.clamp(0, maxCoinReward);
  }

  factory MinigameResult.fromBobaCatchScore(int score) {
    return MinigameResult(
      score: score,
      coinsEarned: coinsForBobaCatchScore(score),
    );
  }

  factory MinigameResult.fromBobaStackScore(int cupsStacked) {
    return MinigameResult(
      score: cupsStacked,
      coinsEarned: coinsForBobaStackScore(cupsStacked),
    );
  }
}
