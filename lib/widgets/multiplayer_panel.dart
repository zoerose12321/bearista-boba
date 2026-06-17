import 'package:flutter/material.dart';

import '../models/local_multiplayer_state.dart';
import '../models/online_cafe_session.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import 'cute_bear_avatar.dart';
import 'host_cafe_card.dart';

/// Inline multiplayer panel for ShopWorldPage (v0.1.47+).
class MultiplayerPanel extends StatelessWidget {
  const MultiplayerPanel({
    super.key,
    required this.player,
    required this.gameState,
    required this.multiplayerState,
    required this.onClose,
    required this.onPurchaseHelper,
    required this.onActivateHelper,
    required this.onSendHelperHome,
    this.onStartLocalCafe,
    this.onEndLocalCafe,
    this.panelMessage,
    this.compact = false,
    this.onlineAvailable = false,
    this.isOnlineHost = false,
    this.isOnlineVisitor = false,
    this.hostedSession,
    this.onlineHostProfileName,
    this.onlineHostShopName,
    this.onlinePanelMessage,
    this.onOpenOnlineCafe,
    this.onCloseOnlineCafe,
    this.onEnterJoinCode,
    this.onLeaveOnlineCafe,
    this.onCopyJoinCode,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;
  final LocalMultiplayerState multiplayerState;
  final VoidCallback onClose;
  final VoidCallback onPurchaseHelper;
  final VoidCallback onActivateHelper;
  final VoidCallback onSendHelperHome;
  final VoidCallback? onStartLocalCafe;
  final VoidCallback? onEndLocalCafe;
  final String? panelMessage;
  final bool compact;
  final bool onlineAvailable;
  final bool isOnlineHost;
  final bool isOnlineVisitor;
  final OnlineCafeSession? hostedSession;
  final String? onlineHostProfileName;
  final String? onlineHostShopName;
  final String? onlinePanelMessage;
  final VoidCallback? onOpenOnlineCafe;
  final VoidCallback? onCloseOnlineCafe;
  final VoidCallback? onEnterJoinCode;
  final VoidCallback? onLeaveOnlineCafe;
  final VoidCallback? onCopyJoinCode;

  String get _statusLabel {
    if (isOnlineVisitor) {
      final hostName = onlineHostProfileName?.trim();
      if (hostName != null && hostName.isNotEmpty) {
        return 'Visiting $hostName\'s Shop Online';
      }
      return 'Visiting Online Café';
    }
    if (isOnlineHost && hostedSession != null) {
      return 'Your café is open online!';
    }
    return multiplayerState.statusLabel;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mp = multiplayerState;
    final combinedMessage = onlinePanelMessage ?? panelMessage;

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
                      _statusLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C4A42),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isOnlineVisitor) ...[
                    Text(
                      onlineHostShopName ?? 'Online Café',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C4A42),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'For now, visitors earn coins for their own profile.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      key: const Key('leave_online_cafe'),
                      onPressed: onLeaveOnlineCafe,
                      child: const Text('Leave Online Café'),
                    ),
                    const SizedBox(height: 12),
                  ] else if (isOnlineHost && hostedSession != null) ...[
                    HostCafeCard(
                      session: hostedSession!,
                      compact: compact,
                      onCopyCode: onCopyJoinCode ?? () {},
                      onCloseCafe: onCloseOnlineCafe ?? () {},
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    MultiplayerOptionTile(
                      title: 'Host Online Café',
                      emoji: '🌐',
                      description:
                          'Open your restaurant online and share a short café code.',
                      compact: compact,
                      actionLabel: onlineAvailable
                          ? 'Open My Café Online'
                          : 'Online unavailable',
                      onAction: onlineAvailable ? onOpenOnlineCafe : null,
                      actionKey: const Key('open_online_cafe'),
                      actionFilled: true,
                    ),
                    const SizedBox(height: 8),
                    MultiplayerOptionTile(
                      title: 'Join Online Café',
                      emoji: '🚪',
                      description:
                          'Enter a friend\'s café code to visit their restaurant online.',
                      compact: compact,
                      actionLabel: onlineAvailable
                          ? 'Enter Café Code'
                          : 'Online unavailable',
                      onAction: onlineAvailable ? onEnterJoinCode : null,
                      actionKey: const Key('enter_cafe_code'),
                      actionFilled: false,
                    ),
                  ],
                  if (combinedMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      combinedMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (!onlineAvailable && !isOnlineHost && !isOnlineVisitor) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Online cafés need Firebase setup and internet. '
                      'Local play still works!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    mp.isHelperActive
                        ? 'Helper Bear is working.'
                        : mp.isHelperBearUnlocked
                            ? 'Activate Helper Bear to serve customers '
                                'automatically.'
                            : 'Buy Helper Bear to help serve customers '
                                'automatically.',
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
                  _HelperBearOptionTile(
                    multiplayerState: mp,
                    coins: gameState.coins,
                    compact: compact,
                    onPurchaseHelper: onPurchaseHelper,
                    onActivateHelper: onActivateHelper,
                    onSendHelperHome: onSendHelperHome,
                  ),
                  const SizedBox(height: 8),
                  MultiplayerOptionTile(
                    title: 'Host a Café',
                    emoji: '🏠',
                    description:
                        'A shared local shift with friends — coming soon.',
                    compact: compact,
                    actionLabel: mp.isLocalCafeActive
                        ? 'Local café running'
                        : 'Start Local Café',
                    onAction: mp.isLocalCafeActive ? null : onStartLocalCafe,
                    actionKey: const Key('start_local_cafe'),
                    actionFilled: false,
                  ),
                  if (mp.isLocalCafeActive && onEndLocalCafe != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      key: const Key('end_local_cafe'),
                      onPressed: onEndLocalCafe,
                      child: const Text('End Local Café'),
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

class _HelperBearOptionTile extends StatelessWidget {
  const _HelperBearOptionTile({
    required this.multiplayerState,
    required this.coins,
    required this.compact,
    required this.onPurchaseHelper,
    required this.onActivateHelper,
    required this.onSendHelperHome,
  });

  final LocalMultiplayerState multiplayerState;
  final int coins;
  final bool compact;
  final VoidCallback onPurchaseHelper;
  final VoidCallback onActivateHelper;
  final VoidCallback onSendHelperHome;

  @override
  Widget build(BuildContext context) {
    final mp = multiplayerState;
    final cost = LocalMultiplayerState.helperBearUnlockCost;

    if (!mp.isHelperBearUnlocked) {
      final canBuy = mp.canPurchaseHelperBear(coins);
      final needed = mp.coinsNeededToUnlock(coins);
      return MultiplayerOptionTile(
        title: 'Helper Bear',
        emoji: '🐻',
        description:
            'Buy Helper Bear to help serve customers automatically.\n'
            'Cost: $cost coins',
        compact: compact,
        actionLabel: canBuy
            ? 'Buy Helper Bear — $cost coins'
            : 'Need $needed more coins',
        onAction: canBuy ? onPurchaseHelper : null,
        actionKey: const Key('buy_helper_bear'),
        actionFilled: true,
      );
    }

    if (mp.isHelperActive) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MultiplayerOptionTile(
            title: 'Helper Bear',
            emoji: '🐻',
            description:
                '${LocalMultiplayerState.helperName} is serving customers for you.',
            compact: compact,
            actionLabel: 'Helper Active',
            onAction: null,
            actionKey: const Key('add_friend_helper'),
            actionFilled: true,
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('send_helper_home'),
            onPressed: onSendHelperHome,
            child: const Text('Send Helper Home'),
          ),
        ],
      );
    }

    return MultiplayerOptionTile(
      title: 'Helper Bear',
      emoji: '🐻',
      description:
          'Call a helper bear to take orders and serve drinks.',
      compact: compact,
      actionLabel: 'Activate Helper Bear',
      onAction: onActivateHelper,
      actionKey: const Key('add_friend_helper'),
      actionFilled: true,
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
