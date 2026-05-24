import 'package:flutter/material.dart';

import '../models/player_character.dart';
import 'cute_bear_avatar.dart';

class ShopCharacter extends StatelessWidget {
  const ShopCharacter({
    super.key,
    required this.furColor,
    required this.accentColor,
    this.muzzleColor = const Color(0xFFFFF0E0),
    this.accessory = BearAccessory.none,
    this.isPanda = false,
    this.sizeScale = 1.0,
    this.nameLabel,
    this.speechText,
    this.size = 64,
    this.isPlayer = false,
  });

  final Color furColor;
  final Color accentColor;
  final Color muzzleColor;
  final BearAccessory accessory;
  final bool isPanda;
  final double sizeScale;
  final String? nameLabel;
  final String? speechText;
  final double size;
  final bool isPlayer;

  @override
  Widget build(BuildContext context) {
    final avatarSize = size * sizeScale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (speechText != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              speechText!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5C4A42),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          padding: EdgeInsets.all(isPlayer ? 6 : 4),
          decoration: BoxDecoration(
            color: isPlayer
                ? const Color(0xFFF5D6A8).withValues(alpha: 0.35)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: CuteBearAvatar(
            furColor: furColor,
            accentColor: accentColor,
            muzzleColor: muzzleColor,
            accessory: accessory,
            isPanda: isPanda,
            size: avatarSize,
            nameLabel: nameLabel,
            showStandingSpot: true,
          ),
        ),
      ],
    );
  }
}

class ShopFurniturePiece extends StatelessWidget {
  const ShopFurniturePiece({
    super.key,
    required this.emoji,
    this.label,
    this.size = 32,
  });

  final String emoji;
  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(emoji, style: TextStyle(fontSize: size)),
        ),
        if (label != null) ...[
          const SizedBox(height: 2),
          Text(
            label!,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C4A42),
            ),
          ),
        ],
      ],
    );
  }
}

class ShopDpad extends StatelessWidget {
  const ShopDpad({super.key, required this.onMove});

  final void Function(int deltaCol, int deltaRow) onMove;

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DpadButton(
            icon: Icons.keyboard_arrow_up_rounded,
            color: buttonColor,
            onPressed: () => onMove(0, -1),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DpadButton(
                icon: Icons.keyboard_arrow_left_rounded,
                color: buttonColor,
                onPressed: () => onMove(-1, 0),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: buttonColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.circle, size: 8, color: buttonColor.withValues(alpha: 0.5)),
              ),
              const SizedBox(width: 8),
              _DpadButton(
                icon: Icons.keyboard_arrow_right_rounded,
                color: buttonColor,
                onPressed: () => onMove(1, 0),
              ),
            ],
          ),
          _DpadButton(
            icon: Icons.keyboard_arrow_down_rounded,
            color: buttonColor,
            onPressed: () => onMove(0, 1),
          ),
        ],
      ),
    );
  }
}

class _DpadButton extends StatelessWidget {
  const _DpadButton({
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
      color: color.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
