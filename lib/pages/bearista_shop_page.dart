import 'package:flutter/material.dart';

import '../data/starter_customers.dart';
import '../models/bear_customer.dart';
import '../models/bearista_character.dart';
import '../models/drink_order.dart';
import '../models/shop_game_state.dart';

class BearistaShopPage extends StatefulWidget {
  const BearistaShopPage({
    super.key,
    required this.character,
    required this.gameState,
  });

  final BearistaCharacter character;
  final ShopGameState gameState;

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

  BearCustomer get _customer => starterCustomers[widget.gameState.currentCustomerIndex];

  DrinkOrder get _selectedDrink =>
      DrinkOrder(ingredients: List.from(_selectedIngredients));

  void _toggleIngredient(String ingredient) {
    if (widget.gameState.orderCompleted) {
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
    if (widget.gameState.orderCompleted) {
      return;
    }

    if (_selectedIngredients.isEmpty) {
      setState(() {
        _message = 'Pick some ingredients first! 🧋';
      });
      return;
    }

    if (_selectedDrink.matches(_customer.order)) {
      setState(() {
        widget.gameState.coins += 10;
        widget.gameState.orderCompleted = true;
        _message = _customer.happyMessage;
        _selectedIngredients.clear();
      });
    } else {
      setState(() {
        _message = _customer.hintMessage;
      });
    }
  }

  void _nextCustomer() {
    setState(() {
      widget.gameState.advanceCustomer(starterCustomers.length);
      _selectedIngredients.clear();
      _message = null;
    });
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
                  Text(widget.character.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.character.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.character.description,
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
                      Text(_customer.emoji, style: const TextStyle(fontSize: 36)),
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
                  onSelected: widget.gameState.orderCompleted
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
                    onPressed: widget.gameState.orderCompleted ? null : _serveDrink,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('Serve Drink'),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.gameState.orderCompleted) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _nextCustomer,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Next Customer'),
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
