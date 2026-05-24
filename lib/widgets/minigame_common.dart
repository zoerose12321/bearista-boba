import 'package:flutter/material.dart';

import '../models/minigame_result.dart';

/// Shared pastel shell for minigame pages.
class MinigamePageShell extends StatelessWidget {
  const MinigamePageShell({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8F0),
              Color(0xFFF5E6D3),
              Color(0xFFEDD9C4),
            ],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

class MinigameScoreBar extends StatelessWidget {
  const MinigameScoreBar({
    super.key,
    required this.scoreLabel,
    required this.secondsLeft,
    required this.coins,
    required this.showTimer,
  });

  final String scoreLabel;
  final int secondsLeft;
  final int coins;
  final bool showTimer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              scoreLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (showTimer)
              Text(
                '${secondsLeft}s',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            if (showTimer) const SizedBox(width: 16),
            Text(
              '🪙 $coins',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MinigameResultPanel extends StatelessWidget {
  const MinigameResultPanel({
    super.key,
    required this.result,
    required this.scoreTitle,
    required this.onPlayAgain,
    required this.onBackToMinigames,
    required this.onBackToCafe,
    this.playAgainKey,
  });

  final MinigameResult result;
  final String scoreTitle;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMinigames;
  final VoidCallback onBackToCafe;
  final Key? playAgainKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Time\'s up!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5C4A42),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              scoreTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              result.coinsEarned > 0
                  ? '+${result.coinsEarned} coins earned!'
                  : 'No coins this round — try again!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: playAgainKey,
              onPressed: onPlayAgain,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Play Again'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onBackToMinigames,
              child: const Text('Back to Mini Games'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onBackToCafe,
              child: const Text('Back to Café'),
            ),
          ],
        ),
      ),
    );
  }
}

void popBackToCafe(BuildContext context) {
  Navigator.of(context)
    ..pop()
    ..pop();
}
