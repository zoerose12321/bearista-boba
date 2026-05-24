import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/starter_customers.dart';
import '../data/starter_furniture.dart';
import '../models/bear_customer.dart';
import '../models/bearista_character.dart';
import '../models/shop_game_state.dart';
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

  int _playerCol = 2;
  int _playerRow = 4;

  BearCustomer get _currentCustomer =>
      starterCustomers[widget.gameState.currentCustomerIndex];

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
              child: Text(
                '🪙 ${widget.gameState.coins}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: _handleKey,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5E6D3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    for (final item in starterFurniture)
                      if (widget.gameState.ownedFurnitureIds.contains(item.id))
                        Align(
                          alignment: item.placement,
                          child: Text(
                            item.emoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                    Align(
                      alignment: Alignment(0.0, -0.35),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentCustomer.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                          Text(
                            _currentCustomer.name,
                            style: theme.textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment(0.85, 0.55),
                      child: const Text('🧋', style: TextStyle(fontSize: 32)),
                    ),
                    Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _gridSize,
                          ),
                          itemCount: _gridSize * _gridSize,
                          itemBuilder: (context, index) {
                            final col = index % _gridSize;
                            final row = index ~/ _gridSize;
                            final isPlayer =
                                col == _playerCol && row == _playerRow;

                            return Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isPlayer
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.35)
                                    : Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: isPlayer
                                  ? Center(
                                      child: Text(
                                        widget.character.emoji,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MoveButton(icon: Icons.arrow_upward, onPressed: () => _move(0, -1)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MoveButton(icon: Icons.arrow_back, onPressed: () => _move(-1, 0)),
                  const SizedBox(width: 12),
                  _MoveButton(icon: Icons.arrow_downward, onPressed: () => _move(0, 1)),
                  const SizedBox(width: 12),
                  _MoveButton(icon: Icons.arrow_forward, onPressed: () => _move(1, 0)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _openBearistaShop,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _MoveButton extends StatelessWidget {
  const _MoveButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
