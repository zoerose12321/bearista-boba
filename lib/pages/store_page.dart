import 'package:flutter/material.dart';

import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../widgets/cute_bear_avatar.dart';

class StorePage extends StatelessWidget {
  const StorePage({
    super.key,
    required this.player,
    required this.gameState,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bearista Store'),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StoreSignBanner(theme: theme),
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
                          '🪙 ${gameState.coins}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Welcome, ${player.displayName}!',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _StoreFloor(
                  player: player,
                  theme: theme,
                ),
                const SizedBox(height: 20),
                Text(
                  'Browse the shelves',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5C4A42),
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 520;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StorePlaceholderSection(
                          width: isWide
                              ? (constraints.maxWidth - 12) / 2
                              : constraints.maxWidth,
                          emoji: '👗',
                          title: 'Outfit Rack',
                          message: 'Outfits coming soon',
                          accent: const Color(0xFFF5A8C8),
                        ),
                        _StorePlaceholderSection(
                          width: isWide
                              ? (constraints.maxWidth - 12) / 2
                              : constraints.maxWidth,
                          emoji: '🎀',
                          title: 'Accessory Shelf',
                          message: 'Accessories coming soon',
                          accent: const Color(0xFFC9B8E8),
                        ),
                        _StorePlaceholderSection(
                          width: isWide
                              ? (constraints.maxWidth - 12) / 2
                              : constraints.maxWidth,
                          emoji: '🪑',
                          title: 'Furniture Display',
                          message: 'Furniture coming soon',
                          accent: const Color(0xFFB8D4A8),
                        ),
                        _StorePlaceholderSection(
                          width: isWide
                              ? (constraints.maxWidth - 12) / 2
                              : constraints.maxWidth,
                          emoji: '🛒',
                          title: 'Checkout Counter',
                          message: 'Purchases coming soon',
                          accent: const Color(0xFFF5D6A8),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreSignBanner extends StatelessWidget {
  const _StoreSignBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8A598), Color(0xFFF5C4BC)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8A598).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧋', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Text(
            'Boba Town Store',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          const Text('🛍️', style: TextStyle(fontSize: 28)),
        ],
      ),
    );
  }
}

class _StoreFloor extends StatelessWidget {
  const _StoreFloor({
    required this.player,
    required this.theme,
  });

  final PlayerCharacter player;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, 0.35),
            radius: 1.1,
            colors: [
              const Color(0xFFFFF8F0),
              const Color(0xFFF5E6D3),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFD4A574).withValues(alpha: 0.35),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 18,
              child: _ShelfDecor(
                emoji: '👕',
                label: 'Rack',
                color: const Color(0xFFF5A8C8).withValues(alpha: 0.35),
              ),
            ),
            Positioned(
              right: 16,
              top: 18,
              child: _ShelfDecor(
                emoji: '🪴',
                label: 'Plants',
                color: const Color(0xFFB8D4A8).withValues(alpha: 0.35),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFE8C9A0).withValues(alpha: 0.35),
                      const Color(0xFFD4A574).withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5D6A8).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: CuteBearAvatar(
                      furColor: player.furColor,
                      accentColor: player.accentColor,
                      accessory: player.accessory,
                      isPanda: player.isPanda,
                      size: 88,
                      nameLabel: player.displayName,
                      showStandingSpot: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Shopping in Boba Town',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShelfDecor extends StatelessWidget {
  const _ShelfDecor({
    required this.emoji,
    required this.label,
    required this.color,
  });

  final String emoji;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5C4A42),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorePlaceholderSection extends StatelessWidget {
  const _StorePlaceholderSection({
    required this.width,
    required this.emoji,
    required this.title,
    required this.message,
    required this.accent,
  });

  final double width;
  final String emoji;
  final String title;
  final String message;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
