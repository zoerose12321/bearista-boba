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

  /// Boba Stack: 1 coin per 2 cups stacked (integer division).
  static int coinsForBobaStackScore(int cupsStacked, {int maxCoinReward = maxCoinReward}) {
    if (cupsStacked <= 0) {
      return 0;
    }
    return (cupsStacked ~/ 2).clamp(0, maxCoinReward);
  }

  /// Tea Time Dash: 2 coins per completed drink sequence.
  static int coinsForTeaTimeDashScore(
    int drinksCompleted, {
    int maxCoinReward = maxCoinReward,
  }) {
    if (drinksCompleted <= 0) {
      return 0;
    }
    return (drinksCompleted * 2).clamp(0, maxCoinReward);
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

  factory MinigameResult.fromTeaTimeDashScore(int drinksCompleted) {
    return MinigameResult(
      score: drinksCompleted,
      coinsEarned: coinsForTeaTimeDashScore(drinksCompleted),
    );
  }
}
