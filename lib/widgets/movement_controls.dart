import 'package:flutter/material.dart';

import '../models/control_style.dart';
import 'shop_decoration.dart';

/// Movement controls for ShopWorldPage — arrow D-pad or Joy-Con style pad.
class MovementControls extends StatelessWidget {
  const MovementControls({
    super.key,
    required this.style,
    required this.onMove,
  });

  final ControlStyle style;
  final void Function(int deltaCol, int deltaRow) onMove;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case ControlStyle.arrows:
        return ShopDpad(onMove: onMove);
      case ControlStyle.joyCon:
        return JoyConPad(onMove: onMove);
    }
  }
}

/// Virtual Joy-Con style directional pad with tap zones.
class JoyConPad extends StatelessWidget {
  const JoyConPad({super.key, required this.onMove});

  final void Function(int deltaCol, int deltaRow) onMove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shellColor = theme.colorScheme.secondary.withValues(alpha: 0.42);
    final accentColor = theme.colorScheme.secondary;
    const padWidth = 92.0;
    const padHeight = 168.0;

    return Container(
      width: padWidth,
      height: padHeight,
      decoration: BoxDecoration(
        color: shellColor,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.55),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 6,
            left: 20,
            right: 20,
            height: 40,
            child: _JoyConZone(
              key: const Key('joycon_up'),
              onTap: () => onMove(0, -1),
            ),
          ),
          Positioned(
            bottom: 6,
            left: 20,
            right: 20,
            height: 40,
            child: _JoyConZone(
              key: const Key('joycon_down'),
              onTap: () => onMove(0, 1),
            ),
          ),
          Positioned(
            left: 6,
            top: 48,
            bottom: 48,
            width: 34,
            child: _JoyConZone(
              key: const Key('joycon_left'),
              onTap: () => onMove(-1, 0),
            ),
          ),
          Positioned(
            right: 6,
            top: 48,
            bottom: 48,
            width: 34,
            child: _JoyConZone(
              key: const Key('joycon_right'),
              onTap: () => onMove(1, 0),
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.65),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoyConZone extends StatelessWidget {
  const _JoyConZone({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: accentColor.withValues(alpha: 0.2),
        highlightColor: accentColor.withValues(alpha: 0.12),
        child: const SizedBox.expand(),
      ),
    );
  }
}
