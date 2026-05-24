import 'package:flutter/material.dart';

import '../models/bear_customer.dart';
import '../models/player_character.dart';
import 'shop_decoration.dart';

/// Normalized layout anchors (0–1 within the walkable floor).
class _SceneLayout {
  static const plantNorm = Offset(0.10, 0.12);
  static const table1Norm = Offset(0.20, 0.28);
  static const table2Norm = Offset(0.26, 0.50);
  static const table3Norm = Offset(0.34, 0.66);
  static const cozyTableNorm = Offset(0.14, 0.42);
  static const comfyChairNorm = Offset(0.40, 0.48);
  static const rugNorm = Offset(0.30, 0.56);

  static const counterRightFrac = 0.05;
  static const counterTopFrac = 0.07;
  static const counterWidthFrac = 0.36;
  static const counterHeightFrac = 0.13;
  static const counterLegWidthFrac = 0.09;
  static const counterLegHeightFrac = 0.20;
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
      playerNormX >= 0.62 && playerNormY <= 0.22;

  Offset _normToScene(double normX, double normY, Size size) {
    const floorLeft = 0.06;
    const floorRight = 0.94;
    const floorTop = 0.06;
    const floorBottom = 0.94;

    final x = size.width * (floorLeft + normX * (floorRight - floorLeft));
    final y = size.height * (floorTop + normY * (floorBottom - floorTop));
    return Offset(x, y);
  }

  Offset _anchorTopLeft(
    Offset norm,
    Size sceneSize, {
    required double width,
    required double height,
  }) {
    final center = _normToScene(norm.dx, norm.dy, sceneSize);
    return Offset(center.dx - width / 2, center.dy - height / 2);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final tableW = size.width * 0.13;
        final tableH = size.width * 0.085;

        final counterRight = size.width * _SceneLayout.counterRightFrac;
        final counterTop = size.height * _SceneLayout.counterTopFrac;
        final counterWidth = size.width * _SceneLayout.counterWidthFrac;
        final counterHeight = size.height * _SceneLayout.counterHeightFrac;
        final counterLegWidth = size.width * _SceneLayout.counterLegWidthFrac;
        final counterLegHeight = size.height * _SceneLayout.counterLegHeightFrac;

        final playerPos = _normToScene(playerNormX, playerNormY, size);
        final customerAnchor = _anchorTopLeft(
          Offset(customerNormX, customerNormY),
          size,
          width: 96,
          height: 120,
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              const _RestaurantRoom(),
              if (_owns('pastel_rug'))
                Positioned(
                  left: _anchorTopLeft(
                    _SceneLayout.rugNorm,
                    size,
                    width: size.width * 0.26,
                    height: size.width * 0.17,
                  ).dx,
                  top: _anchorTopLeft(
                    _SceneLayout.rugNorm,
                    size,
                    width: size.width * 0.26,
                    height: size.width * 0.17,
                  ).dy,
                  child: TopDownRug(
                    width: size.width * 0.26,
                    height: size.width * 0.17,
                  ),
                ),
              _buildTableAt(_SceneLayout.table1Norm, size, tableW, tableH),
              _buildTableAt(_SceneLayout.table2Norm, size, tableW * 0.95, tableH * 0.95,
                  stoolColor: const Color(0xFFF5D6A8)),
              _buildTableAt(
                _SceneLayout.table3Norm,
                size,
                tableW * 0.9,
                tableH * 0.9,
                tableColor: const Color(0xFFD4A574),
                tableChild: const Text('☕', style: TextStyle(fontSize: 14)),
              ),
              if (_owns('cozy_table'))
                _buildTableAt(
                  _SceneLayout.cozyTableNorm,
                  size,
                  tableW,
                  tableH,
                  tableColor: const Color(0xFFD4A574),
                  tableChild: const Text('🪵', style: TextStyle(fontSize: 16)),
                ),
              Positioned(
                left: _anchorTopLeft(_SceneLayout.plantNorm, size,
                        width: size.width * 0.09, height: size.width * 0.09)
                    .dx,
                top: _anchorTopLeft(_SceneLayout.plantNorm, size,
                        width: size.width * 0.09, height: size.width * 0.09)
                    .dy,
                child: TopDownPlant(size: size.width * 0.09),
              ),
              Positioned(
                left: size.width * 0.04,
                bottom: size.height * 0.05,
                child: TopDownDoor(width: size.width * 0.14),
              ),
              Positioned(
                right: counterRight,
                top: counterTop,
                child: TopDownCounter(
                  width: counterWidth,
                  height: counterHeight,
                ),
              ),
              Positioned(
                right: counterRight,
                top: counterTop,
                child: Container(
                  width: counterLegWidth,
                  height: counterLegHeight,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE8C9A0), Color(0xFFD4A574)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                  ),
                ),
              ),
              if (_owns('boba_wall_sign'))
                Positioned(
                  top: size.height * 0.02,
                  right: size.width * 0.08,
                  child: const TopDownWallSign(),
                ),
              Positioned(
                right: counterRight + counterLegWidth + 6,
                top: counterTop - size.height * 0.02,
                child: _CounterMenuBoard(),
              ),
              Positioned(
                right: counterRight + counterLegWidth * 0.2,
                top: counterTop + counterHeight + 10,
                child: const TopDownRegister(),
              ),
              Positioned(
                right: counterRight + counterWidth * 0.38,
                top: counterTop + counterHeight * 0.28,
                child: const Text('🧋', style: TextStyle(fontSize: 18)),
              ),
              if (_owns('flower_vase'))
                Positioned(
                  right: counterRight + counterWidth * 0.62,
                  top: counterTop + counterHeight * 0.22,
                  child: const Text('🌸', style: TextStyle(fontSize: 18)),
                ),
              if (_owns('comfy_chair'))
                Positioned(
                  left: _anchorTopLeft(
                    _SceneLayout.comfyChairNorm,
                    size,
                    width: 36,
                    height: 52,
                  ).dx,
                  top: _anchorTopLeft(
                    _SceneLayout.comfyChairNorm,
                    size,
                    width: 36,
                    height: 52,
                  ).dy,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8A598),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🪑', style: TextStyle(fontSize: 13)),
                      ),
                      const SizedBox(height: 2),
                      const TopDownStool(size: 16, color: Color(0xFFE8A598)),
                    ],
                  ),
                ),
              Positioned(
                left: customerAnchor.dx,
                top: customerAnchor.dy,
                child: ShopCharacter(
                  furColor: customer.furColor,
                  accentColor: customer.accentColor,
                  muzzleColor: customer.muzzleColor,
                  accessory: customer.accessory,
                  isPanda: customer.isPanda,
                  sizeScale: customer.sizeScale,
                  nameLabel: customer.name,
                  speechText: playerNearCustomer ? 'Ready to order?' : null,
                  size: 46,
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                left: playerPos.dx - 44,
                top: playerPos.dy - 72,
                child: Opacity(
                  opacity: _playerBehindCounter ? 0.88 : 1.0,
                  child: ShopCharacter(
                    furColor: player.furColor,
                    accentColor: player.accentColor,
                    accessory: player.accessory,
                    isPanda: player.isPanda,
                    size: 42,
                    isPlayer: true,
                  ),
                ),
              ),
              if (_playerBehindCounter)
                Positioned(
                  right: counterRight + counterLegWidth + counterWidth * 0.52,
                  top: counterTop,
                  child: _CounterSideLip(height: counterHeight + counterLegHeight * 0.4),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableAt(
    Offset norm,
    Size sceneSize,
    double tableW,
    double tableH, {
    Color tableColor = const Color(0xFFE0C9A8),
    Color stoolColor = const Color(0xFFE8A598),
    Widget? tableChild,
  }) {
    final tableSetW = tableW * 1.6;
    final tableSetH = tableH * 1.8;
    final pos = _anchorTopLeft(norm, sceneSize, width: tableSetW, height: tableSetH);

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: TopDownTableSet(
        tableWidth: tableW,
        tableHeight: tableH,
        tableColor: tableColor,
        stoolColor: stoolColor,
        tableChild: tableChild,
      ),
    );
  }
}

class _CounterSideLip extends StatelessWidget {
  const _CounterSideLip({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFFC4956A),
            const Color(0xFFB8845A).withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(-2, 2),
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
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF5C4A42),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFD4A574), width: 2),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('MENU', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text('🍵', style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _RestaurantRoom extends StatelessWidget {
  const _RestaurantRoom();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.2, 0.4),
          radius: 1.15,
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
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 40.0;
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
