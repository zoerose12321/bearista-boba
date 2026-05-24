import 'package:flutter/material.dart';

import '../models/custom_recipe.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../widgets/minigame_common.dart';

enum _CreatorPhase { editing, unlocked }

class TeaTimeDashGamePage extends StatefulWidget {
  const TeaTimeDashGamePage({
    super.key,
    required this.player,
    required this.gameState,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;

  @override
  State<TeaTimeDashGamePage> createState() => _TeaTimeDashGamePageState();
}

class _TeaTimeDashGamePageState extends State<TeaTimeDashGamePage> {
  final _nameController = TextEditingController();
  int _suggestionIndex = 0;

  String? _tea;
  String? _milk;
  String? _topping;
  String? _flavor;
  String? _message;
  _CreatorPhase _phase = _CreatorPhase.editing;
  CustomRecipe? _createdRecipe;

  bool get _isComplete =>
      _tea != null && _milk != null && _topping != null && _flavor != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _applySuggestion(String name) {
    setState(() {
      _nameController.text = name;
      _message = null;
    });
  }

  void _cycleSuggestion() {
    setState(() {
      _suggestionIndex++;
      _nameController.text = CustomRecipe.nameSuggestions[
          _suggestionIndex % CustomRecipe.nameSuggestions.length];
      _message = null;
    });
  }

  String _recipeName() {
    final typed = _nameController.text.trim();
    if (typed.isNotEmpty) {
      return typed;
    }
    return CustomRecipe.generateName(
      tea: _tea,
      milk: _milk,
      topping: _topping,
      flavor: _flavor,
      suggestionIndex: _suggestionIndex,
    );
  }

  void _createRecipe() {
    if (!_isComplete) {
      setState(() {
        _message = 'Pick one tea, milk, topping, and flavor to continue! 🧋';
      });
      return;
    }

    final recipe = CustomRecipe(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _recipeName(),
      ingredients: CustomRecipe.ingredientsFromSelections(
        tea: _tea,
        milk: _milk,
        topping: _topping,
        flavor: _flavor,
      ),
    );

    widget.gameState.addCustomRecipe(recipe);

    setState(() {
      _createdRecipe = recipe;
      _phase = _CreatorPhase.unlocked;
      _message = null;
    });
  }

  void _createAnother() {
    setState(() {
      _phase = _CreatorPhase.editing;
      _createdRecipe = null;
      _tea = null;
      _milk = null;
      _topping = null;
      _flavor = null;
      _nameController.clear();
      _suggestionIndex = 0;
      _message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MinigamePageShell(
      title: 'Tea Time Dash',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: _phase == _CreatorPhase.unlocked
            ? SingleChildScrollView(
                child: _UnlockPanel(
                  recipe: _createdRecipe!,
                  onCreateAnother: _createAnother,
                  onBackToMinigames: () => Navigator.of(context).pop(),
                  onBackToCafe: () => popBackToCafe(context),
                ),
              )
            : SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create your own boba recipe!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5C4A42),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose one from each group, name your drink, '
                        'and unlock Recipe Bear as a special café guest.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _IngredientGroup(
                        groupId: 'tea',
                        title: 'Tea base',
                        options: CustomRecipe.teaBases,
                        selected: _tea,
                        onSelected: (value) => setState(() {
                          _tea = value;
                          _message = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _IngredientGroup(
                        groupId: 'milk',
                        title: 'Milk',
                        options: CustomRecipe.milks,
                        selected: _milk,
                        onSelected: (value) => setState(() {
                          _milk = value;
                          _message = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _IngredientGroup(
                        groupId: 'topping',
                        title: 'Topping',
                        options: CustomRecipe.toppings,
                        selected: _topping,
                        onSelected: (value) => setState(() {
                          _topping = value;
                          _message = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _IngredientGroup(
                        groupId: 'flavor',
                        title: 'Flavor / special',
                        options: CustomRecipe.flavors,
                        selected: _flavor,
                        onSelected: (value) => setState(() {
                          _flavor = value;
                          _message = null;
                        }),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Recipe name',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5C4A42),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        key: const Key('recipe_name_field'),
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Name your cozy creation…',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        onChanged: (_) => setState(() => _message = null),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final name in CustomRecipe.nameSuggestions)
                            ActionChip(
                              label: Text(name),
                              onPressed: () => _applySuggestion(name),
                            ),
                          ActionChip(
                            label: const Text('Shuffle name'),
                            onPressed: _cycleSuggestion,
                          ),
                        ],
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _message!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        key: const Key('create_recipe_button'),
                        onPressed: _isComplete ? _createRecipe : _createRecipe,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Create Recipe'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                      if (!_isComplete)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Select all four ingredient groups to unlock Create Recipe.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55),
                            ),
                            textAlign: TextAlign.center,
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

class _IngredientGroup extends StatelessWidget {
  const _IngredientGroup({
    required this.groupId,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String groupId;
  final String title;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5C4A42),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                return ChoiceChip(
                  key: Key('recipe_${groupId}_$option'),
                  label: Text(option),
                  selected: selected == option,
                  onSelected: (_) => onSelected(option),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnlockPanel extends StatelessWidget {
  const _UnlockPanel({
    required this.recipe,
    required this.onCreateAnother,
    required this.onBackToMinigames,
    required this.onBackToCafe,
  });

  final CustomRecipe recipe;
  final VoidCallback onCreateAnother;
  final VoidCallback onBackToMinigames;
  final VoidCallback onBackToCafe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '✨ Recipe Created!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5C4A42),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  recipe.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.order.displayText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8C9F5).withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('✨🐻', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(
                        'Recipe Bear unlocked!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5C4A42),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your special guest may visit the café and order '
                        'your custom recipe.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.75),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  key: const Key('create_another_recipe'),
                  onPressed: onCreateAnother,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Another Recipe'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: onBackToMinigames,
                  child: const Text('Back to Mini Games'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onBackToCafe,
                  child: const Text('Back to Café'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
