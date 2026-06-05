import 'package:flutter/material.dart';

import '../models/control_style.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../widgets/music_toggle_button.dart';
import 'shop_world_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ControlStyle _controlStyle = ControlStyle.arrows;

  void _selectControlStyle(ControlStyle style) {
    setState(() {
      _controlStyle = style;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 40, 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stackedHeader = constraints.maxWidth < 360;

                  if (stackedHeader) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: MusicToggleButton(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _ControlStyleSelector(
                          selected: _controlStyle,
                          onSelected: _selectControlStyle,
                        ),
                      ],
                    );
                  }

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth.clamp(0, 480),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Center(
                              child: _ControlStyleSelector(
                                selected: _controlStyle,
                                onSelected: _selectControlStyle,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 12, top: 2),
                            child: MusicToggleButton(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                          Text(
                            '🧋',
                            style: theme.textTheme.displayLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bearista Boba',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Run your cozy boba café',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap your bear in the café to customize',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          FilledButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) => ShopWorldPage(
                                    player: PlayerCharacter.defaultBearista(),
                                    gameState: ShopGameState(),
                                    controlStyle: _controlStyle,
                                  ),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 4,
                              ),
                              child: Text('Start'),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlStyleSelector extends StatelessWidget {
  const _ControlStyleSelector({
    required this.selected,
    required this.onSelected,
  });

  final ControlStyle selected;
  final ValueChanged<ControlStyle> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Movement controls',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ControlStyleOption(
                key: const Key('control_style_arrows'),
                label: 'Arrows',
                isSelected: selected == ControlStyle.arrows,
                onTap: () => onSelected(ControlStyle.arrows),
              ),
              const SizedBox(width: 4),
              _ControlStyleOption(
                key: const Key('control_style_joycon'),
                label: 'Joy-Con',
                isSelected: selected == ControlStyle.joyCon,
                onTap: () => onSelected(ControlStyle.joyCon),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlStyleOption extends StatelessWidget {
  const _ControlStyleOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.22)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF5C4A42),
            ),
          ),
        ),
      ),
    );
  }
}
