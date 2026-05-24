import 'package:flutter/material.dart';

import '../data/store_items.dart';
import '../models/shop_game_state.dart';
import '../models/store_item.dart';

class StoreCategoryPage extends StatefulWidget {
  const StoreCategoryPage({
    super.key,
    required this.category,
    required this.gameState,
  });

  final StoreCategory category;
  final ShopGameState gameState;

  @override
  State<StoreCategoryPage> createState() => _StoreCategoryPageState();
}

class _StoreCategoryPageState extends State<StoreCategoryPage> {
  String? _message;

  List<StoreItem> get _items => storeItemsForCategory(widget.category);

  bool _isOwned(StoreItem item) =>
      widget.gameState.ownsStoreItem(item.id);

  void _buyItem(StoreItem item) {
    if (_isOwned(item)) {
      return;
    }

    if (widget.gameState.coins < item.cost) {
      final needed = item.cost - widget.gameState.coins;
      setState(() {
        _message = 'Need $needed more coins for ${item.name}.';
      });
      return;
    }

    final purchased = widget.gameState.tryPurchaseStoreItem(
      id: item.id,
      cost: item.cost,
    );

    if (!purchased) {
      return;
    }

    setState(() {
      _message = '${item.name} is now yours! ${item.emoji}';
    });
  }

  String? _ownedNote(StoreItem item) {
    if (!_isOwned(item)) {
      return null;
    }
    if (item.category == StoreCategory.furniture) {
      return 'Purchased for your café.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8F0),
              Color(0xFFF5E6D3),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🪙 ${widget.gameState.coins} coins',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.category.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
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
            ..._items.map((item) {
              final isOwned = _isOwned(item);
              final canAfford = widget.gameState.coins >= item.cost;
              final ownedNote = _ownedNote(item);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary
                                .withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '🪙 ${item.cost} coins',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              if (ownedNote != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  ownedNote,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              if (!isOwned && !canAfford) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Need ${item.cost - widget.gameState.coins} more coins',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isOwned)
                          Chip(
                            label: const Text('Owned'),
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                          )
                        else
                          FilledButton(
                            onPressed: canAfford ? () => _buyItem(item) : null,
                            child: const Text('Buy'),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
