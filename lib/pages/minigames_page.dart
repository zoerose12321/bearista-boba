import 'package:flutter/material.dart';

import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../widgets/cute_bear_avatar.dart';
import 'boba_catch_game_page.dart';
import 'boba_stack_game_page.dart';
import 'tea_time_dash_game_page.dart';

class MinigamesPage extends StatefulWidget {
  const MinigamesPage({
    super.key,
    required this.player,
    required this.gameState,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;

  @override
  State<MinigamesPage> createState() => _MinigamesPageState();
}

class _MinigamesPageState extends State<MinigamesPage> {
  Future<void> _openGame(Widget page) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (context) => page),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openBobaCatch() => _openGame(
        BobaCatchGamePage(
          player: widget.player,
          gameState: widget.gameState,
        ),
      );

  Future<void> _openBobaStack() => _openGame(
        BobaStackGamePage(
          player: widget.player,
          gameState: widget.gameState,
        ),
      );

  Future<void> _openTeaTimeDash() => _openGame(
        TeaTimeDashGamePage(
          player: widget.player,
          gameState: widget.gameState,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boba Games'),
      ),
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
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 520;
              final cardWidth = isWide
                  ? (constraints.maxWidth - 36) / 2
                  : constraints.maxWidth;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _GamesBanner(theme: theme),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '🪙 ${widget.gameState.coins}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.player.displayName,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF5C4A42),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                PlayerBearAvatar(
                                  player: widget.player,
                                  size: 40,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Pick a game',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C4A42),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MinigameCard(
                          width: cardWidth,
                          title: 'Boba Catch',
                          emoji: '🧋',
                          description:
                              'Catch falling boba pearls with your cup! Earn up to 15 coins.',
                          playKey: const Key('minigame_play_boba_catch'),
                          onTap: _openBobaCatch,
                        ),
                        _MinigameCard(
                          width: cardWidth,
                          title: 'Boba Stack',
                          emoji: '🥛',
                          description:
                              'Stack cups as high as you can! Earn 1 coin per 2 cups.',
                          playKey: const Key('minigame_play_boba_stack'),
                          onTap: _openBobaStack,
                        ),
                        _MinigameCard(
                          width: cardWidth,
                          title: 'Tea Time Dash',
                          emoji: '🍵',
                          description:
                              'Create your own boba recipe and unlock a special bear customer.',
                          playKey: const Key('minigame_play_tea_time_dash'),
                          onTap: _openTeaTimeDash,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GamesBanner extends StatelessWidget {
  const _GamesBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8A598), Color(0xFFD4897A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🎮', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mini Games',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Play cozy arcade games and earn coins!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MinigameCard extends StatelessWidget {
  const _MinigameCard({
    required this.width,
    required this.title,
    required this.emoji,
    required this.description,
    required this.onTap,
    this.playKey,
  });

  final double width;
  final String title;
  final String emoji;
  final String description;
  final VoidCallback onTap;
  final Key? playKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5C4A42),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: playKey,
                  onPressed: onTap,
                  child: const Text('Play'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
