import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/starter_customers.dart';
import '../models/bear_customer.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../widgets/cartoon_shop_scene.dart';
import '../widgets/shop_decoration.dart';
import 'bearista_shop_page.dart';
import 'shop_upgrades_page.dart';

class ShopWorldPage extends StatefulWidget {
  const ShopWorldPage({
    super.key,
    required this.player,
    required this.gameState,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;

  @override
  State<ShopWorldPage> createState() => _ShopWorldPageState();
}

class _ShopWorldPageState extends State<ShopWorldPage> {
  static const _horizontalStep = 0.05;
  static const _verticalStep = 0.09;

  static const _customerNormX = 0.55;
  static const _customerNormY = 0.38;
  static const _talkRangeInSteps = 6.0;

  static const _minX = RestaurantSceneScale.moveMinX;
  static const _maxX = RestaurantSceneScale.moveMaxX;
  static const _minY = RestaurantSceneScale.moveMinY;
  static const _maxY = RestaurantSceneScale.moveMaxY;

  /// Walk-path start — clear of entry door, open floor toward counter.
  double _playerNormX = 0.36;
  double _playerNormY = 0.68;

  BearCustomer get _currentCustomer =>
      starterCustomers[widget.gameState.currentCustomerIndex];

  bool get _isNearCustomer {
    final dx = (_playerNormX - _customerNormX).abs();
    final dy = (_playerNormY - _customerNormY).abs();
    final distanceInSteps = dx / _horizontalStep + dy / _verticalStep;
    return distanceInSteps <= _talkRangeInSteps;
  }

  void _move(int deltaCol, int deltaRow) {
    setState(() {
      if (deltaCol != 0) {
        _playerNormX = (_playerNormX + deltaCol * _horizontalStep)
            .clamp(_minX, _maxX);
      }
      if (deltaRow != 0) {
        _playerNormY = (_playerNormY + deltaRow * _verticalStep)
            .clamp(_minY, _maxY);
      }
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
          player: widget.player,
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
        title: Text('${widget.player.displayName}\'s Shop'),
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
                  child: ShopSceneViewport(
                    child: CartoonShopScene(
                      playerNormX: _playerNormX,
                      playerNormY: _playerNormY,
                      customerNormX: _customerNormX,
                      customerNormY: _customerNormY,
                      player: widget.player,
                      customer: _currentCustomer,
                      ownedFurnitureIds: widget.gameState.ownedFurnitureIds,
                      playerNearCustomer: _isNearCustomer,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: ShopSceneLayout.controlsMaxWidth,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
