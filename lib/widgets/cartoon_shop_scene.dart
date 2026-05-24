import 'package:flutter/material.dart';

import '../models/bear_customer.dart';
import 'shop_decoration.dart';

class CartoonShopScene extends StatelessWidget {
  const CartoonShopScene({
    super.key,
    required this.gridSize,
    required this.playerNormX,
    required this.playerNormY,
    required this.customerCol,
    required this.customerRow,
    required this.characterEmoji,
    required this.customer,
    required this.ownedFurnitureIds,
    required this.playerNearCustomer,
  });

  final int gridSize;
  final double playerNormX;
  final double playerNormY;
  final int customerCol;
  final int customerRow;
  final String characterEmoji;
  final BearCustomer customer;
  final Set<String> ownedFurnitureIds;
  final bool playerNearCustomer;

  bool _owns(String id) => ownedFurnitureIds.contains(id);

  Offset _normToScene(double normX, double normY, Size size) {
    const floorLeft = 0.1;
    const floorRight = 0.9;
    const floorTop = 0.46;
    const floorBottom = 0.94;

    final x = size.width * (floorLeft + normX * (floorRight - floorLeft));
    final y = size.height * (floorTop + normY * (floorBottom - floorTop));
    return Offset(x, y);
  }

  Offset _gridToScene(int col, int row, Size size) {
    const floorLeft = 0.1;
    const floorRight = 0.9;
    const floorTop = 0.46;
    const floorBottom = 0.94;

    final x = size.width *
        (floorLeft + (col / (gridSize - 1)) * (floorRight - floorLeft));
    final y = size.height *
        (floorTop + (row / (gridSize - 1)) * (floorBottom - floorTop));
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final playerPosition = _normToScene(playerNormX, playerNormY, size);
        final customerPosition = _gridToScene(customerCol, customerRow, size);

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _WallBackground(),
              _FloorArea(showRug: _owns('pastel_rug')),
              const _ServiceCounter(),
              const _MenuBoard(),
              const _BobaStation(),
              const _WallPlant(),
              _SeatingArea(
                showTable: _owns('cozy_table'),
                showChair: _owns('comfy_chair'),
              ),
              if (_owns('boba_wall_sign'))
                const Align(
                  alignment: Alignment(0, -0.88),
                  child: ShopFurniturePiece(
                    emoji: '🧋',
                    label: 'Bearista',
                    size: 42,
                  ),
                ),
              if (_owns('flower_vase'))
                Positioned(
                  left: size.width * 0.72,
                  top: size.height * 0.24,
                  child: const ShopFurniturePiece(
                    emoji: '🌸',
                    size: 30,
                  ),
                ),
              Positioned(
                left: customerPosition.dx - 42,
                top: customerPosition.dy - 72,
                child: ShopCharacter(
                  emoji: customer.emoji,
                  nameLabel: customer.name,
                  speechText: playerNearCustomer ? 'Ready to order?' : null,
                  size: 46,
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                left: playerPosition.dx - 38,
                top: playerPosition.dy - 58,
                child: ShopCharacter(
                  emoji: characterEmoji,
                  size: 40,
                  isPlayer: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WallBackground extends StatelessWidget {
  const _WallBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFAD9CF),
            Color(0xFFF8EBE4),
            Color(0xFFF5E6D3),
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          width: double.infinity,
          height: 8,
          color: Colors.white.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _FloorArea extends StatelessWidget {
  const _FloorArea({required this.showRug});

  final bool showRug;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.72),
      child: FractionallySizedBox(
        widthFactor: 0.88,
        heightFactor: 0.52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8D4BE),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            if (showRug)
              FractionallySizedBox(
                widthFactor: 0.62,
                heightFactor: 0.55,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFF5C6D6).withValues(alpha: 0.85),
                        const Color(0xFFC6D9F5).withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.7),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🧶', style: TextStyle(fontSize: 28)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCounter extends StatelessWidget {
  const _ServiceCounter();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.18),
      child: FractionallySizedBox(
        widthFactor: 0.92,
        heightFactor: 0.18,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFD4A574),
                Color(0xFFC4956A),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment(-0.55, 0.2),
                child: Text('☕', style: TextStyle(fontSize: 22)),
              ),
              const Align(
                alignment: Alignment(0.55, 0.2),
                child: Text('🧋', style: TextStyle(fontSize: 22)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuBoard extends StatelessWidget {
  const _MenuBoard();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.82, -0.55),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF5C4A42),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4A574), width: 3),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('MENU', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('🍵', style: TextStyle(fontSize: 16)),
            Text('🥛', style: TextStyle(fontSize: 14)),
            Text('🫧', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _BobaStation extends StatelessWidget {
  const _BobaStation();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.78, -0.42),
      child: Container(
        width: 64,
        height: 78,
        decoration: BoxDecoration(
          color: const Color(0xFFE8A598),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🧋', style: TextStyle(fontSize: 26)),
            SizedBox(height: 2),
            Text('Boba', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5C4A42))),
          ],
        ),
      ),
    );
  }
}

class _WallPlant extends StatelessWidget {
  const _WallPlant();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.9, -0.72),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFB8D4A8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
            ),
            alignment: Alignment.center,
            child: const Text('🪴', style: TextStyle(fontSize: 20)),
          ),
          Container(
            width: 28,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A574),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatingArea extends StatelessWidget {
  const _SeatingArea({
    required this.showTable,
    required this.showChair,
  });

  final bool showTable;
  final bool showChair;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.72, 0.58),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showChair)
            const Padding(
              padding: EdgeInsets.only(right: 4, bottom: 2),
              child: ShopFurniturePiece(emoji: '🪑', size: 34),
            ),
          Container(
            width: showTable ? 72 : 52,
            height: showTable ? 40 : 28,
            decoration: BoxDecoration(
              color: showTable ? const Color(0xFFD4A574) : const Color(0xFFE0C9A8),
              borderRadius: BorderRadius.circular(showTable ? 14 : 10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: Text(
              showTable ? '🪵' : '☕',
              style: TextStyle(fontSize: showTable ? 24 : 18),
            ),
          ),
        ],
      ),
    );
  }
}
