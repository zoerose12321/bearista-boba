import 'package:flutter/material.dart';

import '../data/starter_furniture.dart';
import '../models/furniture_upgrade.dart';
import '../models/shop_game_state.dart';

class ShopUpgradesPage extends StatefulWidget {
  const ShopUpgradesPage({
    super.key,
    required this.gameState,
  });

  final ShopGameState gameState;

  @override
  State<ShopUpgradesPage> createState() => _ShopUpgradesPageState();
}

class _ShopUpgradesPageState extends State<ShopUpgradesPage> {
  String? _message;

  void _buyFurniture(FurnitureUpgrade item) {
    if (widget.gameState.ownedFurnitureIds.contains(item.id)) {
      return;
    }

    if (widget.gameState.coins < item.cost) {
      final needed = item.cost - widget.gameState.coins;
      setState(() {
        _message = 'You need $needed more coins for ${item.name}.';
      });
      return;
    }

    setState(() {
      widget.gameState.coins -= item.cost;
      widget.gameState.ownedFurnitureIds.add(item.id);
      _message = '${item.name} is now in your shop! ${item.emoji}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Upgrades'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '🪙 ${widget.gameState.coins} coins',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Card(
              color: theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_message!),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...starterFurniture.map((item) {
            final isOwned = widget.gameState.ownedFurnitureIds.contains(item.id);
            final canAfford = widget.gameState.coins >= item.cost;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('${item.cost} coins'),
                            if (isOwned)
                              Text(
                                'Owned',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else if (!canAfford)
                              Text(
                                'Need ${item.cost - widget.gameState.coins} more coins',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: isOwned ? null : () => _buyFurniture(item),
                        child: Text(isOwned ? 'Owned' : 'Buy'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
