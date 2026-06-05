import 'package:flutter/material.dart';

/// Compact arrow pad for Player 2 / Friend Bear (v0.1.52+).
class P2MovementControls extends StatelessWidget {
  const P2MovementControls({super.key, required this.onMove});

  final void Function(int deltaCol, int deltaRow) onMove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = theme.colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'P2 Controls',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5C4A42),
            ),
          ),
          const SizedBox(height: 6),
          _P2Button(
            key: const Key('p2_up'),
            icon: Icons.keyboard_arrow_up_rounded,
            color: buttonColor,
            onPressed: () => onMove(0, -1),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _P2Button(
                key: const Key('p2_left'),
                icon: Icons.keyboard_arrow_left_rounded,
                color: buttonColor,
                onPressed: () => onMove(-1, 0),
              ),
              const SizedBox(width: 4),
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                child: Text(
                  'P2',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5C4A42),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _P2Button(
                key: const Key('p2_right'),
                icon: Icons.keyboard_arrow_right_rounded,
                color: buttonColor,
                onPressed: () => onMove(1, 0),
              ),
            ],
          ),
          _P2Button(
            key: const Key('p2_down'),
            icon: Icons.keyboard_arrow_down_rounded,
            color: buttonColor,
            onPressed: () => onMove(0, 1),
          ),
        ],
      ),
    );
  }
}

class _P2Button extends StatelessWidget {
  const _P2Button({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
