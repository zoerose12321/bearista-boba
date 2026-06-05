import 'package:flutter/material.dart';

import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import 'cute_bear_avatar.dart';

/// Inline multiplayer placeholder panel for ShopWorldPage (v0.1.47+).
class MultiplayerPanel extends StatelessWidget {
  const MultiplayerPanel({
    super.key,
    required this.player,
    required this.gameState,
    required this.onClose,
    this.compact = false,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;
  final VoidCallback onClose;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.brown.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 0),
            child: Row(
              children: [
                const Text('👥', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Multiplayer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5C4A42),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('multiplayer_panel_close'),
                  onPressed: onClose,
                  tooltip: 'Close',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cozy café visits with friends are on the way!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5C4A42),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Multiplayer is being planned. Soon you may host a café, '
                    'join a friend, and share boba fun together.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '🪙 ${gameState.coins}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              player.displayName,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF5C4A42),
                              ),
                            ),
                            const SizedBox(height: 4),
                            PlayerBearAvatar(player: player, size: 36),
                          ],
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Coming soon',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5C4A42),
                    ),
                  ),
                  const SizedBox(height: 8),
                  MultiplayerOptionTile(
                    title: 'Host a Café',
                    emoji: '🏠',
                    description:
                        'Open your shop for friends to visit and order together.',
                    compact: compact,
                  ),
                  const SizedBox(height: 8),
                  MultiplayerOptionTile(
                    title: 'Join a Café',
                    emoji: '🚪',
                    description:
                        'Hop into a friend\'s cozy boba shop for a shared shift.',
                    compact: compact,
                  ),
                  const SizedBox(height: 8),
                  MultiplayerOptionTile(
                    title: 'Invite Friends',
                    emoji: '💌',
                    description:
                        'Send a friendly invite when multiplayer arrives.',
                    compact: compact,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MultiplayerOptionTile extends StatelessWidget {
  const MultiplayerOptionTile({
    super.key,
    required this.title,
    required this.emoji,
    required this.description,
    this.compact = false,
  });

  final String title;
  final String emoji;
  final String description;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: compact ? 20 : 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: (compact
                          ? theme.textTheme.titleSmall
                          : theme.textTheme.titleMedium)
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5C4A42),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: const Text('Coming soon'),
            ),
          ),
        ],
      ),
    );
  }
}
