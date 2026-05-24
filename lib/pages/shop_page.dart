import 'package:flutter/material.dart';

import '../data/starter_customers.dart';
import '../models/bearista_character.dart';
import '../models/drink_order.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key, required this.character});

  final BearistaCharacter character;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  static const _availableIngredients = [
    'Black Tea',
    'Green Tea',
    'Milk',
    'Oat Milk',
    'Tapioca Pearls',
    'Boba Jelly',
  ];

  final _customer = starterCustomers.first;

  int _coins = 0;
  final List<String> _selectedIngredients = [];
  String? _message;

  DrinkOrder get _selectedDrink => DrinkOrder(ingredients: List.from(_selectedIngredients));

  void _toggleIngredient(String ingredient) {
    setState(() {
      _message = null;
      if (_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.remove(ingredient);
      } else {
        _selectedIngredients.add(ingredient);
      }
    });
  }

  void _serveDrink() {
    if (_selectedIngredients.isEmpty) {
      setState(() {
        _message = 'Pick some ingredients first! 🧋';
      });
      return;
    }

    if (_selectedDrink.matches(_customer.order)) {
      setState(() {
        _coins += 10;
        _message = 'Perfect! Honey Bear loves it! 🍯✨ +10 coins';
        _selectedIngredients.clear();
      });
    } else {
      setState(() {
        _message =
            'Not quite right… Honey Bear wanted something with tea, milk, and pearls. Try again! 💛';
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
                  '🪙 $_coins',
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
                onSelected: (_) => _toggleIngredient(ingredient),
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
          FilledButton(
            onPressed: _serveDrink,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Serve Drink'),
            ),
          ),
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
