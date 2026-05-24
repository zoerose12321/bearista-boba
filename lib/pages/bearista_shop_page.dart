import 'package:flutter/material.dart';

import '../models/bear_customer.dart';
import '../models/player_character.dart';
import '../models/drink_order.dart';
import '../models/shop_game_state.dart';
import '../services/coin_reward_service.dart';
import '../services/sound_effects_service.dart';
import '../widgets/cute_bear_avatar.dart';

class BearistaShopPage extends StatefulWidget {
  const BearistaShopPage({
    super.key,
    required this.player,
    required this.gameState,
    required this.customer,
    this.orderCompleted = false,
    this.coinReward,
    this.onOrderCompleted,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;
  final BearCustomer customer;
  final bool orderCompleted;
  final int? coinReward;
  final void Function(int coinReward)? onOrderCompleted;

  @override
  State<BearistaShopPage> createState() => _BearistaShopPageState();
}

class _BearistaShopPageState extends State<BearistaShopPage> {
  static const _availableIngredients = [
    'Black Tea',
    'Green Tea',
    'Strawberry Tea',
    'Milk',
    'Oat Milk',
    'Tapioca Pearls',
    'Boba Jelly',
  ];

  final List<String> _selectedIngredients = [];
  String? _message;
  late bool _orderCompleted;
  int? _coinReward;

  BearCustomer get _customer => widget.customer;

  DrinkOrder get _selectedDrink =>
      DrinkOrder(ingredients: List.from(_selectedIngredients));

  @override
  void initState() {
    super.initState();
    _orderCompleted = widget.orderCompleted;
    _coinReward = widget.coinReward;
    if (_orderCompleted && _coinReward != null) {
      _message = _customer.happyMessageWithReward(_coinReward!);
    }
  }

  void _toggleIngredient(String ingredient) {
    if (_orderCompleted) {
      return;
    }

    setState(() {
      _message = null;
      if (_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.remove(ingredient);
      } else {
        _selectedIngredients.add(ingredient);
      }
    });
  }

  void _clearDrink() {
    setState(() {
      _selectedIngredients.clear();
      _message = null;
    });
  }

  void _serveDrink() {
    if (_orderCompleted) {
      return;
    }

    if (_selectedIngredients.isEmpty) {
      setState(() {
        _message = 'Pick some ingredients first! 🧋';
      });
      return;
    }

    if (_selectedDrink.matches(_customer.order)) {
      final reward = CoinRewardService.rollReward();
      setState(() {
        widget.gameState.coins += reward;
        _orderCompleted = true;
        _coinReward = reward;
        _message = _customer.happyMessageWithReward(reward);
        _selectedIngredients.clear();
      });
      widget.onOrderCompleted?.call(reward);
      SoundEffectsService.instance.playCoinDing();
    } else {
      setState(() {
        _message = _customer.hintMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bearista Shop'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InfoCard(
              child: Row(
                children: [
                  PlayerBearAvatar(
                    player: widget.player,
                    size: 56,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.player.displayName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your bearista',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '🪙 ${widget.gameState.coins}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CuteBearAvatar(
                        furColor: _customer.furColor,
                        accentColor: _customer.accentColor,
                        muzzleColor: _customer.muzzleColor,
                        accessory: _customer.accessory,
                        isPanda: _customer.isPanda,
                        size: 52 * _customer.sizeScale,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _customer.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Order:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _customer.order.displayText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ingredients',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIngredients.map((ingredient) {
                final isSelected = _selectedIngredients.contains(ingredient);
                return FilterChip(
                  label: Text(ingredient),
                  selected: isSelected,
                  onSelected: _orderCompleted
                      ? null
                      : (_) => _toggleIngredient(ingredient),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Drink',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedIngredients.isEmpty
                        ? 'Tap ingredients to build a drink…'
                        : _selectedDrink.displayText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              _InfoCard(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Text(
                  _message!,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearDrink,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('Clear Drink'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _orderCompleted ? null : _serveDrink,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('Serve Drink'),
                    ),
                  ),
                ),
              ],
            ),
            if (_orderCompleted) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Back to Shop'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.child,
    this.backgroundColor,
  });

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
