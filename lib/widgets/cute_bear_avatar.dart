import 'package:flutter/material.dart';

import '../models/player_character.dart';

class CuteBearAvatar extends StatelessWidget {
  const CuteBearAvatar({
    super.key,
    required this.furColor,
    required this.accentColor,
    this.muzzleColor = const Color(0xFFFFF0E0),
    this.cheekColor,
    this.accessory = BearAccessory.none,
    this.apronColor,
    this.isPanda = false,
    this.size = 64,
    this.nameLabel,
    this.specialBadgeEmoji,
    this.showStandingSpot = false,
  });

  final Color furColor;
  final Color accentColor;
  final Color muzzleColor;
  final Color? cheekColor;
  final BearAccessory accessory;
  final Color? apronColor;
  final bool isPanda;
  final double size;
  final String? nameLabel;
  final String? specialBadgeEmoji;
  final bool showStandingSpot;

  @override
  Widget build(BuildContext context) {
    final headSize = size * 0.72;
    final bodyWidth = size * 0.62;
    final bodyHeight = size * 0.38;
    final earSize = size * 0.22;
    final muzzleSize = size * 0.34;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (nameLabel != null) ...[
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size * 1.35),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size * 0.12,
                vertical: size * 0.05,
              ),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(size * 0.14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
              ),
              child: Text(
                nameLabel!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: nameLabel!.length > 14 ? size * 0.13 : size * 0.16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5C4A42),
                ),
              ),
            ),
          ),
          SizedBox(height: size * 0.06),
        ],
        SizedBox(
          width: size,
          height: size * 1.05,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              if (showStandingSpot)
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: size * 0.55,
                    height: size * 0.1,
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(size),
                    ),
                  ),
                ),
              Positioned(
                bottom: size * 0.06,
                child: Container(
                  width: bodyWidth,
                  height: bodyHeight,
                  decoration: BoxDecoration(
                    color: isPanda ? Colors.white : furColor,
                    borderRadius: BorderRadius.circular(size * 0.2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.55),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      if (apronColor != null) ...[
                        Positioned(
                          top: size * 0.02,
                          child: Container(
                            width: size * 0.08,
                            height: size * 0.08,
                            decoration: BoxDecoration(
                              color: apronColor!.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(size * 0.03),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: size * 0.07,
                              left: size * 0.02,
                              right: size * 0.02,
                              bottom: size * 0.02,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: apronColor,
                                borderRadius:
                                    BorderRadius.circular(size * 0.14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.brown.withValues(alpha: 0.08),
                                    blurRadius: 2,
                                    offset: Offset(0, size * 0.02),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: EdgeInsets.only(top: size * 0.05),
                            width: size * 0.12,
                            height: size * 0.12,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: size * 0.22,
                child: SizedBox(
                  width: headSize,
                  height: headSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: headSize * 0.02,
                        top: -earSize * 0.35,
                        child: _Ear(
                          size: earSize,
                          color: isPanda ? const Color(0xFF3D3D3D) : furColor,
                        ),
                      ),
                      Positioned(
                        right: headSize * 0.02,
                        top: -earSize * 0.35,
                        child: _Ear(
                          size: earSize,
                          color: isPanda ? const Color(0xFF3D3D3D) : furColor,
                        ),
                      ),
                      Container(
                        width: headSize,
                        height: headSize,
                        decoration: BoxDecoration(
                          color: isPanda ? Colors.white : furColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.65),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.brown.withValues(alpha: 0.12),
                              blurRadius: size * 0.08,
                              offset: Offset(0, size * 0.03),
                            ),
                          ],
                        ),
                      ),
                      if (isPanda) ...[
                        Positioned(
                          left: headSize * 0.14,
                          top: headSize * 0.34,
                          child: _EyePatch(size: headSize * 0.22),
                        ),
                        Positioned(
                          right: headSize * 0.14,
                          top: headSize * 0.34,
                          child: _EyePatch(size: headSize * 0.22),
                        ),
                      ],
                      Positioned(
                        bottom: headSize * 0.18,
                        child: Container(
                          width: muzzleSize,
                          height: muzzleSize * 0.82,
                          decoration: BoxDecoration(
                            color: isPanda ? const Color(0xFFF0F0F0) : muzzleColor,
                            borderRadius: BorderRadius.circular(muzzleSize),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: muzzleSize * 0.18,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _Eye(size: size * 0.06),
                                    SizedBox(width: size * 0.1),
                                    _Eye(size: size * 0.06),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: muzzleSize * 0.22,
                                child: Container(
                                  width: size * 0.07,
                                  height: size * 0.05,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5C4A42),
                                    borderRadius: BorderRadius.circular(size * 0.04),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: headSize * 0.1,
                        bottom: headSize * 0.28,
                        child: _Blush(
                          size: size * 0.07,
                          color: cheekColor,
                        ),
                      ),
                      Positioned(
                        right: headSize * 0.1,
                        bottom: headSize * 0.28,
                        child: _Blush(
                          size: size * 0.07,
                          color: cheekColor,
                        ),
                      ),
                      if (accessory == BearAccessory.bow)
                        Positioned(
                          top: -earSize * 0.1,
                          child: Text('🎀', style: TextStyle(fontSize: size * 0.22)),
                        ),
                      if (accessory == BearAccessory.tinyHat)
                        Positioned(
                          top: -earSize * 0.55,
                          child: Container(
                            width: size * 0.34,
                            height: size * 0.16,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(size * 0.05),
                              border: Border.all(color: const Color(0xFF5C4A42), width: 1),
                            ),
                          ),
                        ),
                      if (accessory == BearAccessory.glasses)
                        Positioned(
                          top: headSize * 0.36,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _GlassesLens(size: size * 0.11),
                              Container(
                                width: size * 0.05,
                                height: 2,
                                color: const Color(0xFF5C4A42),
                              ),
                              _GlassesLens(size: size * 0.11),
                            ],
                          ),
                        ),
                      if (accessory == BearAccessory.flower)
                        Positioned(
                          right: -size * 0.04,
                          top: headSize * 0.18,
                          child: Text('🌸', style: TextStyle(fontSize: size * 0.18)),
                        ),
                      if (specialBadgeEmoji != null)
                        Positioned(
                          right: -size * 0.02,
                          top: -earSize * 0.15,
                          child: Text(
                            specialBadgeEmoji!,
                            style: TextStyle(fontSize: size * 0.2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Player bear with equipped store outfit and accessory applied.
class PlayerBearAvatar extends StatelessWidget {
  const PlayerBearAvatar({
    super.key,
    required this.player,
    this.size = 64,
    this.nameLabel,
    this.showStandingSpot = false,
  });

  final PlayerCharacter player;
  final double size;
  final String? nameLabel;
  final bool showStandingSpot;

  @override
  Widget build(BuildContext context) {
    return CuteBearAvatar(
      furColor: player.furColor,
      accentColor: player.accentColor,
      accessory: player.displayAccessory,
      apronColor: player.equippedApronColor,
      isPanda: player.isPanda,
      size: size,
      nameLabel: nameLabel,
      showStandingSpot: showStandingSpot,
    );
  }
}

class _Ear extends StatelessWidget {
  const _Ear({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Align(
        child: Container(
          width: size * 0.55,
          height: size * 0.55,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF5C4A42),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _EyePatch extends StatelessWidget {
  const _EyePatch({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.1,
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D3D),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

class _Blush extends StatelessWidget {
  const _Blush({required this.size, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.65,
      decoration: BoxDecoration(
        color: (color ?? const Color(0xFFF5A8C8)).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

class _GlassesLens extends StatelessWidget {
  const _GlassesLens({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF5C4A42), width: 2),
        color: Colors.white.withValues(alpha: 0.25),
      ),
    );
  }
}
