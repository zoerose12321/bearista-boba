import 'package:flutter/material.dart';

import '../models/local_multiplayer_state.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import 'cute_bear_avatar.dart';

/// Inline multiplayer panel for ShopWorldPage (v0.1.47+).
class MultiplayerPanel extends StatelessWidget {
  const MultiplayerPanel({
    super.key,
    required this.player,
    required this.gameState,
    required this.multiplayerState,
    required this.onClose,
    required this.onStartLocalCafe,
    required this.onAddFriendHelper,
    required this.onEndMultiplayer,
    this.compact = false,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;
  final LocalMultiplayerState multiplayerState;
  final VoidCallback onClose;
  final VoidCallback onStartLocalCafe;
  final VoidCallback onAddFriendHelper;
  final VoidCallback onEndMultiplayer;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mp = multiplayerState;

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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      mp.statusLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C4A42),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cozy café visits with friends are on the way!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5C4A42),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mp.isMultiplayerActive
                        ? 'Share your café locally — move around together '
                            'and help greet customers.'
                        : 'Start a local session to try couch-co-op in your '
                            'café before online visits arrive.',
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
                  MultiplayerOptionTile(
                    title: 'Host a Café',
                    emoji: '🏠',
                    description:
                        'Open your shop for a shared local shift.',
                    compact: compact,
                    actionLabel: mp.isMultiplayerActive
                        ? 'Local café running'
                        : 'Start Local Café',
                    onAction: mp.isMultiplayerActive ? null : onStartLocalCafe,
                    actionKey: const Key('start_local_cafe'),
                    actionFilled: true,
                  ),
                  const SizedBox(height: 8),
                  MultiplayerOptionTile(
                    title: 'Join a Café',
                    emoji: '🚪',
                    description: mp.isFriendHelperActive
                        ? '${LocalMultiplayerState.friendName} is helping in the café.'
                        : 'Add a second bear to wander the floor with you.',
                    compact: compact,
                    actionLabel: 'Add Friend Helper',
                    onAction: mp.isMultiplayerActive && !mp.isFriendHelperActive
                        ? onAddFriendHelper
                        : null,
                    actionKey: const Key('add_friend_helper'),
                    actionFilled: true,
                  ),
                  const SizedBox(height: 8),
                  MultiplayerOptionTile(
                    title: 'Invite Friends',
                    emoji: '💌',
                    description:
                        'Online invites and friend codes are coming later.',
                    compact: compact,
                    actionLabel: 'Online invites later',
                    onAction: null,
                  ),
                  if (mp.isMultiplayerActive) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      key: const Key('end_multiplayer'),
                      onPressed: onEndMultiplayer,
                      child: const Text('End Multiplayer'),
                    ),
                  ],
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
    required this.actionLabel,
    this.onAction,
    this.actionKey,
    this.actionFilled = false,
    this.compact = false,
  });

  final String title;
  final String emoji;
  final String description;
  final String actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;
  final bool actionFilled;
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
            child: actionFilled
                ? FilledButton(
                    key: actionKey,
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: Text(actionLabel),
                  )
                : OutlinedButton(
                    key: actionKey,
                    onPressed: onAction,
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: Text(actionLabel),
                  ),
          ),
        ],
      ),
    );
  }
}
