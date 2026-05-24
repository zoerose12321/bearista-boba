import 'package:flutter/material.dart';

import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../widgets/cute_bear_avatar.dart';
import 'shop_world_page.dart';

class CharacterCreatorPage extends StatefulWidget {
  const CharacterCreatorPage({super.key});

  @override
  State<CharacterCreatorPage> createState() => _CharacterCreatorPageState();
}

class _CharacterCreatorPageState extends State<CharacterCreatorPage> {
  final _nameController = TextEditingController(text: 'Bearista');

  BearFur _fur = BearFur.honey;
  BearAccent _accent = BearAccent.peach;
  BearAccessory _accessory = BearAccessory.none;

  PlayerCharacter get _previewCharacter => PlayerCharacter(
        name: _nameController.text,
        fur: _fur,
        accent: _accent,
        accessory: _accessory,
      );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continueToShop() {
    final player = _previewCharacter;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ShopWorldPage(
          player: player,
          gameState: ShopGameState(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _previewCharacter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Bearista'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Preview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CuteBearAvatar(
                          furColor: preview.furColor,
                          accentColor: preview.accentColor,
                          accessory: preview.accessory,
                          isPanda: preview.isPanda,
                          size: 96,
                          nameLabel: preview.displayName,
                          showStandingSpot: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Bearista Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                Text(
                  'Fur Color',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BearFur.values.map((fur) {
                    return ChoiceChip(
                      label: Text(fur.label),
                      selected: _fur == fur,
                      onSelected: (_) => setState(() => _fur = fur),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Outfit Accent',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BearAccent.values.map((accent) {
                    return ChoiceChip(
                      avatar: CircleAvatar(backgroundColor: accent.color, radius: 10),
                      label: Text(accent.label),
                      selected: _accent == accent,
                      onSelected: (_) => setState(() => _accent = accent),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Accessory',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BearAccessory.values.map((accessory) {
                    final label = accessory == BearAccessory.none
                        ? accessory.label
                        : '${accessory.label} ${accessory.emoji}';
                    return ChoiceChip(
                      label: Text(label),
                      selected: _accessory == accessory,
                      onSelected: (_) => setState(() => _accessory = accessory),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              key: const Key('continue_to_shop'),
              onPressed: _continueToShop,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Continue to Shop'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
