import 'package:flutter/material.dart';

import '../models/bear_customer.dart';
import '../models/player_character.dart';
import 'shop_decoration.dart';

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

  /// Player is in the work area behind the right-side counter.
  bool get _playerBehindCounter =>
      playerNormX >= 0.58 && playerNormY <= 0.28;

  Offset _normToScene(double normX, double normY, Size size) {
    const floorLeft = 0.06;
    const floorRight = 0.94;
    const floorTop = 0.06;
    const floorBottom = 0.94;

    final x = size.width * (floorLeft + normX * (floorRight - floorLeft));
    final y = size.height * (floorTop + normY * (floorBottom - floorTop));
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final playerPosition = _normToScene(playerNormX, playerNormY, size);
        final customerPosition = _normToScene(customerNormX, customerNormY, size);
        final tableW = size.width * 0.15;
        final tableH = size.width * 0.10;

        final counterRight = size.width * 0.04;
        final counterTop = size.height * 0.06;
        final counterWidth = size.width * 0.44;
        final counterHeight = size.height * 0.14;
        final counterLegWidth = size.width * 0.11;
        final counterLegHeight = size.height * 0.24;

        final playerWidget = ShopCharacter(
          furColor: player.furColor,
          accentColor: player.accentColor,
          accessory: player.accessory,
          isPanda: player.isPanda,
          size: 44,
          isPlayer: true,
        );

        final customerWidget = ShopCharacter(
          furColor: customer.furColor,
          accentColor: customer.accentColor,
          muzzleColor: customer.muzzleColor,
          accessory: customer.accessory,
          isPanda: customer.isPanda,
          sizeScale: customer.sizeScale,
          nameLabel: customer.name,
          speechText: playerNearCustomer ? 'Ready to order?' : null,
          size: 48,
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _RestaurantRoom(),
              if (_owns('pastel_rug'))
                Align(
                  alignment: const Alignment(-0.15, 0.18),
                  child: TopDownRug(
                    width: size.width * 0.30,
                    height: size.width * 0.20,
                  ),
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
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                  ),
                ),
              ),
              Positioned(
                left: size.width * 0.14,
                top: size.height * 0.36,
                child: TopDownTableSet(
                  tableWidth: tableW,
                  tableHeight: tableH,
                  tableColor: const Color(0xFFE0C9A8),
                ),
              ),
              Positioned(
                left: size.width * 0.34,
                top: size.height * 0.50,
                child: TopDownTableSet(
                  tableWidth: tableW * 0.95,
                  tableHeight: tableH * 0.95,
                  tableColor: const Color(0xFFE0C9A8),
                  stoolColor: const Color(0xFFF5D6A8),
                ),
              ),
              Positioned(
                left: size.width * 0.22,
                bottom: size.height * 0.30,
                child: TopDownTableSet(
                  tableWidth: tableW * 0.9,
                  tableHeight: tableH * 0.9,
                  tableColor: const Color(0xFFD4A574),
                  tableChild: const Text('☕', style: TextStyle(fontSize: 16)),
                ),
              ),
              if (_owns('cozy_table'))
                Positioned(
                  left: size.width * 0.08,
                  top: size.height * 0.52,
                  child: TopDownTableSet(
                    tableWidth: tableW * 1.05,
                    tableHeight: tableH * 1.05,
                    tableColor: const Color(0xFFD4A574),
                    tableChild: const Text('🪵', style: TextStyle(fontSize: 18)),
                  ),
                ),
              if (_owns('comfy_chair'))
                Positioned(
                  left: size.width * 0.42,
                  top: size.height * 0.44,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8A598),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🪑', style: TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(height: 2),
                      const TopDownStool(size: 18, color: Color(0xFFE8A598)),
                    ],
                  ),
                ),
              Positioned(
                left: size.width * 0.06,
                top: size.height * 0.10,
                child: TopDownPlant(size: size.width * 0.10),
              ),
              Positioned(
                left: size.width * 0.04,
                bottom: size.height * 0.04,
                child: TopDownDoor(width: size.width * 0.16),
              ),
              Positioned(
                left: customerPosition.dx - 48,
                top: customerPosition.dy - 88,
                child: customerWidget,
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                left: playerPosition.dx - 44,
                top: playerPosition.dy - 72,
                child: Opacity(
                  opacity: _playerBehindCounter ? 0.88 : 1.0,
                  child: playerWidget,
                ),
              ),
              if (_playerBehindCounter)
                Positioned(
                  right: counterRight + counterLegWidth + counterWidth * 0.55,
                  top: counterTop,
                  child: _CounterSideLip(height: counterHeight + counterLegHeight * 0.45),
                ),
              if (_owns('boba_wall_sign'))
                Positioned(
                  top: size.height * 0.015,
                  right: size.width * 0.10,
                  child: const TopDownWallSign(),
                ),
              Positioned(
                right: counterRight + counterLegWidth * 0.15,
                top: counterTop + counterHeight * 0.2,
                child: const TopDownRegister(),
              ),
              Positioned(
                right: counterRight + counterWidth * 0.72,
                top: counterTop - size.height * 0.01,
                child: _CounterMenuBoard(),
              ),
              Positioned(
                right: counterRight + counterWidth * 0.42,
                top: counterTop + counterHeight * 0.22,
                child: const Text('🧋', style: TextStyle(fontSize: 20)),
              ),
              if (_owns('flower_vase'))
                Positioned(
                  right: counterRight + counterWidth * 0.18,
                  top: counterTop + counterHeight * 0.15,
                  child: const Text('🌸', style: TextStyle(fontSize: 20)),
                ),
            ],
          ),
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
      width: 12,
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
        borderRadius: BorderRadius.circular(6),
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
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF5C4A42),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4A574), width: 2),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('MENU', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text('🍵', style: TextStyle(fontSize: 12)),
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
          center: const Alignment(0.25, 0.35),
          radius: 1.2,
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
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 36.0;
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
