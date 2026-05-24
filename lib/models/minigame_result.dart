/// Outcome of a completed minigame round.
class MinigameResult {
  const MinigameResult({
    required this.score,
    required this.coinsEarned,
  });

  final int score;
  final int coinsEarned;

  /// Boba Catch: 1 coin per catch, capped at [maxCoinReward].
  static int coinsForBobaCatchScore(int score, {int maxCoinReward = 15}) {
    if (score <= 0) {
      return 0;
    }
    return score.clamp(0, maxCoinReward);
  }

  factory MinigameResult.fromBobaCatchScore(int score) {
    return MinigameResult(
      score: score,
      coinsEarned: coinsForBobaCatchScore(score),
    );
  }
}
