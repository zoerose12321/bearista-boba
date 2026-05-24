import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/starter_customers.dart';
import '../models/bear_customer.dart';
import '../models/bearista_character.dart';
import '../models/shop_game_state.dart';
import '../widgets/cartoon_shop_scene.dart';
import '../widgets/shop_decoration.dart';
import 'bearista_shop_page.dart';
import 'shop_upgrades_page.dart';

class ShopWorldPage extends StatefulWidget {
  const ShopWorldPage({
    super.key,
    required this.character,
    required this.gameState,
  });

  final BearistaCharacter character;
  final ShopGameState gameState;

  @override
  State<ShopWorldPage> createState() => _ShopWorldPageState();
}

class _ShopWorldPageState extends State<ShopWorldPage> {
  static const _gridSize = 5;
  static const _customerCol = 2;
  static const _customerRow = 1;
  static const _talkRange = 2;

  int _playerCol = 2;
  int _playerRow = 3;

  BearCustomer get _currentCustomer =>
      starterCustomers[widget.gameState.currentCustomerIndex];

  bool get _isNearCustomer {
    final distance =
        (_playerCol - _customerCol).abs() + (_playerRow - _customerRow).abs();
    return distance <= _talkRange;
  }

  void _move(int deltaCol, int deltaRow) {
    setState(() {
      _playerCol = (_playerCol + deltaCol).clamp(0, _gridSize - 1);
      _playerRow = (_playerRow + deltaRow).clamp(0, _gridSize - 1);
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        _move(0, -1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        _move(0, 1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        _move(-1, 0);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _move(1, 0);
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  Future<void> _openBearistaShop() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => BearistaShopPage(
          character: widget.character,
          gameState: widget.gameState,
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _openShopUpgrades() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ShopUpgradesPage(gameState: widget.gameState),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.character.name}\'s Shop'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '🪙 ${widget.gameState.coins}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: _handleKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Expanded(
                  child: CartoonShopScene(
                    gridSize: _gridSize,
                    playerCol: _playerCol,
                    playerRow: _playerRow,
                    customerCol: _customerCol,
                    customerRow: _customerRow,
                    characterEmoji: widget.character.emoji,
                    customer: _currentCustomer,
                    ownedFurnitureIds: widget.gameState.ownedFurnitureIds,
                    playerNearCustomer: _isNearCustomer,
                  ),
                ),
                const SizedBox(height: 12),
                ShopDpad(onMove: _move),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _isNearCustomer
                          ? FilledButton.icon(
                              onPressed: _openBearistaShop,
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Talk'),
                            )
                          : OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Talk'),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openShopUpgrades,
                        icon: const Icon(Icons.storefront_outlined),
                        label: const Text('Shop Upgrades'),
                      ),
                    ),
                  ],
                ),
                if (!_isNearCustomer) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Walk closer to ${_currentCustomer.name} to talk',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
