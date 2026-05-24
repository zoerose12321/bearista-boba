import 'package:flutter/material.dart';

import '../models/bear_customer.dart';
import '../models/player_character.dart';
import 'shop_decoration.dart';

/// Fixed rectangular zones (normalized 0–1 within the restaurant floor).
class _Zone {
  const _Zone(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;
  Offset get center => Offset((left + right) / 2, (top + bottom) / 2);
}

class _RestaurantZones {
  static const entry = _Zone(0.04, 0.80, 0.22, 0.96);
  static const plant = _Zone(0.04, 0.04, 0.17, 0.17);
  static const seatingA = _Zone(0.08, 0.18, 0.34, 0.38);
  static const seatingB = _Zone(0.08, 0.42, 0.34, 0.60);
  static const cozyTableSlot = _Zone(0.08, 0.62, 0.34, 0.76);
  static const rugSlot = _Zone(0.36, 0.52, 0.52, 0.68);
  static const customerArea = _Zone(0.46, 0.30, 0.64, 0.46);
  static const counter = _Zone(0.68, 0.06, 0.94, 0.28);
  static const signSlot = _Zone(0.70, 0.02, 0.92, 0.08);
  // Walk path — kept clear of furniture (entry → customer).
  static const walkPath = _Zone(0.22, 0.38, 0.58, 0.78);
}

class CartoonShopScene extends StatelessWidget {
  const CartoonShopScene({
    super.key,
    required this.playerNormX,
    required this.playerNormY,
    required this.customerNormX,
    required this.customerNormY,
    required this.player,
    required this.customer,
    required this.ownedFurnitureIds,
    required this.playerNearCustomer,
  });

  final double playerNormX;
  final double playerNormY;
  final double customerNormX;
  final double customerNormY;
  final PlayerCharacter player;
  final BearCustomer customer;
  final Set<String> ownedFurnitureIds;
  final bool playerNearCustomer;

  bool _owns(String id) => ownedFurnitureIds.contains(id);

  bool get _playerBehindCounter =>
      playerNormX >= 0.64 && playerNormY <= 0.22;

  Offset _normToScene(double normX, double normY, Size size) {
    const padL = 0.06;
    const padR = 0.94;
    const padT = 0.06;
    const padB = 0.94;
    return Offset(
      size.width * (padL + normX * (padR - padL)),
      size.height * (padT + normY * (padB - padT)),
    );
  }

  Rect _zoneRect(_Zone zone, Size size) {
    return Rect.fromLTWH(
      size.width * zone.left,
      size.height * zone.top,
      size.width * zone.width,
      size.height * zone.height,
    );
  }

  Widget _inZone(
    _Zone zone,
    Size size,
    Widget child, {
    double widthFactor = RestaurantSceneScale.zoneFill,
    double heightFactor = RestaurantSceneScale.zoneFill,
  }) {
    final rect = _zoneRect(zone, size);
    final w = rect.width * widthFactor;
    final h = rect.height * heightFactor;
    return Positioned(
      left: rect.left + (rect.width - w) / 2,
      top: rect.top + (rect.height - h) / 2,
      width: w,
      height: h,
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final tableW = (size.width *
                _RestaurantZones.seatingA.width *
                0.45 *
                RestaurantSceneScale.furniture)
            .clamp(48.0, 68.0);
        final tableH = tableW * 0.65;
        final playerHalfW = RestaurantSceneScale.playerBearSize * 0.55;
        final playerOffsetY = RestaurantSceneScale.playerBearSize * 1.55;
        final customerHalfW = RestaurantSceneScale.customerBearSize * 0.95;

        final playerPos = _normToScene(playerNormX, playerNormY, size);
        final customerRect = _zoneRect(_RestaurantZones.customerArea, size);

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              const _RestaurantRoom(),
              CustomPaint(
                painter: _ZoneGuidePainter(showGuides: false),
                size: size,
              ),
              if (_owns('pastel_rug'))
                _inZone(
                  _RestaurantZones.rugSlot,
                  size,
                  TopDownRug(
                    width: size.width *
                        _RestaurantZones.rugSlot.width *
                        0.9 *
                        RestaurantSceneScale.upgrade,
                    height: size.width *
                        _RestaurantZones.rugSlot.width *
                        0.55 *
                        RestaurantSceneScale.upgrade,
                  ),
                  widthFactor: 0.98,
                  heightFactor: 0.98,
                ),
              _inZone(
                _RestaurantZones.plant,
                size,
                TopDownPlant(
                  size: size.width * 0.075 * RestaurantSceneScale.plant,
                ),
              ),
              _inZone(
                _RestaurantZones.seatingA,
                size,
                RestaurantTableGroup(
                  tableWidth: tableW,
                  tableHeight: tableH,
                ),
              ),
              _inZone(
                _RestaurantZones.seatingB,
                size,
                RestaurantTableGroup(
                  tableWidth: tableW,
                  tableHeight: tableH,
                  stoolColor: const Color(0xFFF5D6A8),
                  comfyChair: _owns('comfy_chair'),
                ),
              ),
              if (_owns('cozy_table'))
                _inZone(
                  _RestaurantZones.cozyTableSlot,
                  size,
                  RestaurantTableGroup(
                    tableWidth: tableW,
                    tableHeight: tableH,
                    tableColor: const Color(0xFFD4A574),
                    tableChild: Text(
                      '🪵',
                      style: TextStyle(fontSize: 14 * RestaurantSceneScale.upgrade),
                    ),
                  ),
                ),
              _inZone(
                _RestaurantZones.entry,
                size,
                FittedBox(
                  fit: BoxFit.contain,
                  child: TopDownDoor(width: 72 * RestaurantSceneScale.entry),
                ),
                widthFactor: 0.92,
                heightFactor: 0.92,
              ),
              _inZone(
                _RestaurantZones.counter,
                size,
                _CounterCluster(
                  showVase: _owns('flower_vase'),
                  scale: RestaurantSceneScale.counter,
                ),
                widthFactor: 0.96,
                heightFactor: 0.96,
              ),
              if (_owns('boba_wall_sign'))
                _inZone(
                  _RestaurantZones.signSlot,
                  size,
                  Transform.scale(
                    scale: RestaurantSceneScale.upgrade,
                    child: const TopDownWallSign(),
                  ),
                  widthFactor: 0.95,
                  heightFactor: 0.95,
                ),
              Positioned(
                left: customerRect.left + (customerRect.width - customerHalfW * 2) / 2,
                top: customerRect.top + 2,
                child: ShopCharacter(
                  furColor: customer.furColor,
                  accentColor: customer.accentColor,
                  muzzleColor: customer.muzzleColor,
                  accessory: customer.accessory,
                  isPanda: customer.isPanda,
                  sizeScale: customer.sizeScale,
                  nameLabel: customer.name,
                  speechText: playerNearCustomer ? 'Ready to order?' : null,
                  size: RestaurantSceneScale.customerBearSize,
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                left: playerPos.dx - playerHalfW,
                top: playerPos.dy - playerOffsetY,
                child: Opacity(
                  opacity: _playerBehindCounter ? 0.88 : 1.0,
                  child: ShopCharacter(
                    furColor: player.furColor,
                    accentColor: player.accentColor,
                    accessory: player.accessory,
                    isPanda: player.isPanda,
                    size: RestaurantSceneScale.playerBearSize,
                    isPlayer: true,
                  ),
                ),
              ),
              if (_playerBehindCounter)
                Positioned(
                  left: _zoneRect(_RestaurantZones.counter, size).left - 8,
                  top: _zoneRect(_RestaurantZones.counter, size).top,
                  child: _CounterSideLip(
                    height: _zoneRect(_RestaurantZones.counter, size).height * 0.85,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CounterCluster extends StatelessWidget {
  const _CounterCluster({
    required this.showVase,
    this.scale = 1.0,
  });

  final bool showVase;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final emojiSize = 18.0 * scale;
        final vaseSize = 16.0 * scale;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: w * 0.06,
              top: h * 0.06,
              right: 0,
              child: TopDownCounter(width: w * 0.90, height: h * 0.46),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: w * 0.24,
                height: h * 0.76,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE8C9A0), Color(0xFFD4A574)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topLeft,
                child: _CounterMenuBoard(),
              ),
            ),
            Positioned(
              right: w * 0.02,
              top: h * 0.46,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topRight,
                child: const TopDownRegister(),
              ),
            ),
            Positioned(
              left: w * 0.40,
              top: h * 0.20,
              child: Text('🧋', style: TextStyle(fontSize: emojiSize)),
            ),
            if (showVase)
              Positioned(
                left: w * 0.60,
                top: h * 0.16,
                child: Text('🌸', style: TextStyle(fontSize: vaseSize)),
              ),
          ],
        );
      },
    );
  }
}

class _CounterSideLip extends StatelessWidget {
  const _CounterSideLip({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFC4956A),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.12),
            blurRadius: 3,
            offset: const Offset(-1, 2),
          ),
        ],
      ),
    );
  }
}

class _CounterMenuBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF5C4A42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4A574), width: 2),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('MENU', style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold)),
          Text('🍵', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

class _ZoneGuidePainter extends CustomPainter {
  _ZoneGuidePainter({required this.showGuides});

  final bool showGuides;

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGuides) {
      return;
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.red.withValues(alpha: 0.2);
    for (final zone in [
      _RestaurantZones.entry,
      _RestaurantZones.plant,
      _RestaurantZones.seatingA,
      _RestaurantZones.seatingB,
      _RestaurantZones.walkPath,
      _RestaurantZones.counter,
    ]) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * zone.left,
          size.height * zone.top,
          size.width * zone.width,
          size.height * zone.height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ZoneGuidePainter oldDelegate) => false;
}

class _RestaurantRoom extends StatelessWidget {
  const _RestaurantRoom();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.15, 0.45),
          radius: 1.1,
          colors: [
            const Color(0xFFFFF8F0),
            const Color(0xFFF5E6D3),
            const Color(0xFFEDD9C4),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFD4A574).withValues(alpha: 0.45),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: CustomPaint(
          painter: _FloorTilePainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _FloorTilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 44.0;
    for (var x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
