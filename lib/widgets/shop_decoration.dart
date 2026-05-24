import 'dart:math' as math;

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
              style: TextStyle(
                fontSize: (size * 0.19).clamp(
                  RestaurantSceneScale.minLabelFontSize,
                  14.0,
                ),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5C4A42),
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

/// Virtual design canvas and responsive scaling for ShopWorldPage (v0.1.11+).
class ShopSceneLayout {
  const ShopSceneLayout._();

  static const designWidth = 900.0;
  static const designHeight = 520.0;

  /// Prevents the restaurant from stretching across ultra-wide web windows.
  static const maxSceneWidth = 900.0;

  static const minSceneScale = 0.55;
  static const maxSceneScale = 1.0;

  /// Keeps D-pad and action buttons from stretching on desktop web.
  static const controlsMaxWidth = 480.0;

  static Size get designSize => const Size(designWidth, designHeight);

  static double scaleFor(double availableWidth, double availableHeight) {
    final cappedWidth = math.min(availableWidth, maxSceneWidth);
    final scaleByWidth = cappedWidth / designWidth;
    final scaleByHeight = availableHeight / designHeight;
    return math.min(scaleByWidth, scaleByHeight)
        .clamp(minSceneScale, maxSceneScale);
  }

  static Size sceneSizeFor(double availableWidth, double availableHeight) {
    final scale = scaleFor(availableWidth, availableHeight);
    return Size(designWidth * scale, designHeight * scale);
  }

  /// Width shared by the scene card and top chrome row.
  static double contentWidthFor(double availableWidth) {
    return math.min(availableWidth, maxSceneWidth);
  }
}

/// Centralized scale constants for the shop world scene (v0.1.10+).
/// Values are expressed in [ShopSceneLayout] design-space pixels.
class RestaurantSceneScale {
  const RestaurantSceneScale._();

  static const furniture = 1.58;
  static const stool = 1.45;
  static const plant = 1.42;
  static const counter = 2.05;
  static const entry = 1.56;
  static const upgrade = 1.62;
  /// Register, menu board, and counter emoji readability boost (v0.1.12+).
  static const detail = 1.38;
  /// Extra detail scale for the enlarged service counter (v0.1.13).
  static const counterDetail = 1.78;
  static const zoneFill = 0.96;

  static const playerBearSize = 68.0;
  static const customerBearSize = 74.0;

  /// Normalized coords for behind-counter movement and visibility.
  static const behindCounterMinX = 0.58;
  static const behindCounterMaxY = 0.30;

  /// Minimum readable label size after scene downscaling.
  static const minLabelFontSize = 10.0;

  /// Movement bounds inset for larger character sprites.
  static const moveMinX = 0.09;
  static const moveMaxX = 0.89;
  static const moveMinY = 0.09;
  static const moveMaxY = 0.84;
}

/// Top header row aligned to the café scene width (v0.1.12+).
class ShopWorldHeader extends StatelessWidget implements PreferredSizeWidget {
  const ShopWorldHeader({
    super.key,
    required this.title,
    required this.coins,
  });

  final String title;
  final int coins;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '🪙 $coins',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Top-down restaurant props for the shop floor plan scene.
class TopDownOvalTable extends StatelessWidget {
  const TopDownOvalTable({
    super.key,
    required this.width,
    required this.height,
    this.color = const Color(0xFFD4A574),
    this.child,
  });

  final double width;
  final double height;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 2),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class TopDownStool extends StatelessWidget {
  const TopDownStool({
    super.key,
    this.size = 16,
    this.color = const Color(0xFFE8A598),
  });

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
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class TopDownTableSet extends StatelessWidget {
  const TopDownTableSet({
    super.key,
    required this.tableWidth,
    required this.tableHeight,
    this.tableColor = const Color(0xFFD4A574),
    this.stoolColor = const Color(0xFFE8A598),
    this.tableChild,
    this.extraStool,
    this.stoolCount = 4,
  });

  final double tableWidth;
  final double tableHeight;
  final Color tableColor;
  final Color stoolColor;
  final Widget? tableChild;
  final Widget? extraStool;
  final int stoolCount;

  static double groupWidth(double tableWidth) => tableWidth * 1.52;
  static double groupHeight(double tableHeight) => tableHeight * 1.60;

  @override
  Widget build(BuildContext context) {
    final stoolSize = tableWidth * 0.24 * RestaurantSceneScale.stool;

    return SizedBox(
      width: groupWidth(tableWidth),
      height: groupHeight(tableHeight),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (stoolCount >= 1)
            Positioned(top: 0, child: TopDownStool(size: stoolSize, color: stoolColor)),
          if (stoolCount >= 2)
            Positioned(
              bottom: 0,
              child: extraStool ?? TopDownStool(size: stoolSize, color: stoolColor),
            ),
          if (stoolCount >= 3)
            Positioned(left: 0, child: TopDownStool(size: stoolSize * 0.85, color: stoolColor)),
          if (stoolCount >= 4)
            Positioned(right: 0, child: TopDownStool(size: stoolSize * 0.85, color: stoolColor)),
          TopDownOvalTable(
            width: tableWidth,
            height: tableHeight,
            color: tableColor,
            child: tableChild,
          ),
        ],
      ),
    );
  }
}

/// Self-contained table + stools sized to fit a layout zone.
class RestaurantTableGroup extends StatelessWidget {
  const RestaurantTableGroup({
    super.key,
    required this.tableWidth,
    required this.tableHeight,
    this.tableColor = const Color(0xFFE0C9A8),
    this.stoolColor = const Color(0xFFE8A598),
    this.tableChild,
    this.comfyChair = false,
  });

  final double tableWidth;
  final double tableHeight;
  final Color tableColor;
  final Color stoolColor;
  final Widget? tableChild;
  final bool comfyChair;

  @override
  Widget build(BuildContext context) {
    return TopDownTableSet(
      tableWidth: tableWidth,
      tableHeight: tableHeight,
      tableColor: tableColor,
      stoolColor: stoolColor,
      tableChild: tableChild,
      extraStool: comfyChair
          ? Container(
              width: tableWidth * 0.32,
              height: tableWidth * 0.32,
              decoration: BoxDecoration(
                color: const Color(0xFFE8A598),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              ),
              alignment: Alignment.center,
              child: Text('🪑', style: TextStyle(fontSize: tableWidth * 0.18)),
            )
          : null,
    );
  }
}

class TopDownCounter extends StatelessWidget {
  const TopDownCounter({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8C9A0), Color(0xFFD4A574)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.14),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: height * 0.25,
            child: Text(
              '🧋',
              style: TextStyle(fontSize: 20 * RestaurantSceneScale.counterDetail),
            ),
          ),
          Positioned(
            right: 16,
            top: height * 0.25,
            child: Text(
              '☕',
              style: TextStyle(fontSize: 18 * RestaurantSceneScale.counterDetail),
            ),
          ),
          Center(
            child: Container(
              width: width * 0.55,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopDownRegister extends StatelessWidget {
  const TopDownRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFE8A598),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '💳',
        style: TextStyle(fontSize: 16 * RestaurantSceneScale.counterDetail),
      ),
    );
  }
}

class TopDownDoor extends StatelessWidget {
  const TopDownDoor({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: width * 0.55,
          decoration: BoxDecoration(
            color: const Color(0xFFC4956A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF8B6914).withValues(alpha: 0.35)),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.door_front_door_outlined,
            color: Colors.white.withValues(alpha: 0.85),
            size: width * 0.35,
          ),
        ),
        Text(
          'Entry',
          style: TextStyle(
            fontSize: width * 0.12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5C4A42).withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class TopDownPlant extends StatelessWidget {
  const TopDownPlant({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFB8D4A8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text('🪴', style: TextStyle(fontSize: size * 0.55)),
    );
  }
}

class TopDownRug extends StatelessWidget {
  const TopDownRug({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF5C6D6).withValues(alpha: 0.75),
            const Color(0xFFC6D9F5).withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(height * 0.4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.65), width: 2),
      ),
      alignment: Alignment.center,
      child: Text('🧶', style: TextStyle(fontSize: 28 * RestaurantSceneScale.upgrade / 1.25)),
    );
  }
}

class TopDownWallSign extends StatelessWidget {
  const TopDownWallSign({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8A598),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🧋', style: TextStyle(fontSize: 18)),
          SizedBox(width: 4),
          Text(
            'Bearista',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C4A42),
            ),
          ),
        ],
      ),
    );
  }
}
