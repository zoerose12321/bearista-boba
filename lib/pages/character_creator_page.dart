import 'package:flutter/material.dart';

import '../models/player_character.dart';
import '../widgets/cute_bear_avatar.dart';

class CharacterCreatorPage extends StatefulWidget {
  const CharacterCreatorPage({
    super.key,
    required this.player,
  });

  final PlayerCharacter player;

  @override
  State<CharacterCreatorPage> createState() => _CharacterCreatorPageState();
}

class _CharacterCreatorPageState extends State<CharacterCreatorPage> {
  late final TextEditingController _nameController;

  late BearFur _fur;
  late BearAccent _accent;
  late BearAccessory _accessory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
    _fur = widget.player.fur;
    _accent = widget.player.accent;
    _accessory = widget.player.accessory;
  }

  PlayerCharacter get _previewCharacter => PlayerCharacter(
        name: _nameController.text,
        fur: _fur,
        accent: _accent,
        accessory: _accessory,
        equippedOutfitId: widget.player.equippedOutfitId,
        equippedAccessoryId: widget.player.equippedAccessoryId,
      );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    widget.player.applyCustomization(
      name: _nameController.text,
      fur: _fur,
      accent: _accent,
      accessory: _accessory,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _previewCharacter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Your Bearista'),
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
                        PlayerBearAvatar(
                          player: preview,
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
                if (widget.player.equippedAccessoryId != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Store accessories stay equipped until changed in the store.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              key: const Key('save_character_changes'),
              onPressed: _saveChanges,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Save Changes'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
