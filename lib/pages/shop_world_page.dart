import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/starter_customers.dart';
import '../models/bear_customer.dart';
import '../models/customer_visit_state.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../widgets/cartoon_shop_scene.dart';
import '../widgets/shop_decoration.dart';
import 'bearista_shop_page.dart';
import 'shop_upgrades_page.dart';

class ShopWorldPage extends StatefulWidget {
  const ShopWorldPage({
    super.key,
    required this.player,
    required this.gameState,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;

  @override
  State<ShopWorldPage> createState() => _ShopWorldPageState();
}

class _ShopWorldPageState extends State<ShopWorldPage>
    with SingleTickerProviderStateMixin {
  static const _horizontalStep = 0.05;
  static const _verticalStep = 0.09;

  static const _talkRangeInSteps = 6.0;

  static const _enterPause = Duration(milliseconds: 400);
  static const _walkDuration = Duration(milliseconds: 1200);

  static const _minX = RestaurantSceneScale.moveMinX;
  static const _maxX = RestaurantSceneScale.moveMaxX;
  static const _minY = RestaurantSceneScale.moveMinY;
  static const _maxY = RestaurantSceneScale.moveMaxY;

  /// Walk-path start — clear of entry door, open floor toward counter.
  double _playerNormX = 0.36;
  double _playerNormY = 0.68;

  CustomerVisitPhase _visitPhase = CustomerVisitPhase.entering;
  int _activeVisitIndex = -1;
  int _visitGeneration = 0;
  CustomerSeatingSpot _targetSeat = CustomerSeatingSpot.tableSeatOne;

  late AnimationController _walkController;

  BearCustomer get _currentCustomer =>
      starterCustomers[widget.gameState.currentCustomerIndex];

  Offset get _customerPosition {
    if (_visitPhase == CustomerVisitPhase.entering) {
      return const Offset(
        CustomerSeatingSpot.entryNormX,
        CustomerSeatingSpot.entryNormY,
      );
    }
    if (_visitPhase == CustomerVisitPhase.seatedReadyToOrder) {
      return Offset(_targetSeat.normX, _targetSeat.normY);
    }

    final t = _walkController.value;
    const midX = CustomerSeatingSpot.midAisleNormX;
    const midY = CustomerSeatingSpot.midAisleNormY;
    final seatX = _targetSeat.normX;
    final seatY = _targetSeat.normY;

    if (t <= 0.5) {
      final seg = t * 2;
      return Offset(
        lerpDouble(CustomerSeatingSpot.entryNormX, midX, seg)!,
        lerpDouble(CustomerSeatingSpot.entryNormY, midY, seg)!,
      );
    }

    final seg = (t - 0.5) * 2;
    return Offset(
      lerpDouble(midX, seatX, seg)!,
      lerpDouble(midY, seatY, seg)!,
    );
  }

  bool _isNearCustomerAt(double normX, double normY) {
    final dx = (_playerNormX - normX).abs();
    final dy = (_playerNormY - normY).abs();
    final distanceInSteps = dx / _horizontalStep + dy / _verticalStep;
    return distanceInSteps <= _talkRangeInSteps;
  }

  bool get _customerIsSeated =>
      _visitPhase == CustomerVisitPhase.seatedReadyToOrder;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(vsync: this, duration: _walkDuration)
      ..addStatusListener(_onWalkStatus);
    _startVisit();
  }

  @override
  void dispose() {
    _walkController.dispose();
    super.dispose();
  }

  void _startVisit() {
    _visitGeneration++;
    final generation = _visitGeneration;

    _walkController.stop();
    _walkController.reset();

    final index = widget.gameState.currentCustomerIndex;
    _activeVisitIndex = index;
    _targetSeat = CustomerSeatingSpot.forCustomerIndex(index);
    _visitPhase = CustomerVisitPhase.entering;

    Future<void>.delayed(_enterPause, () {
      if (!mounted || generation != _visitGeneration) {
        return;
      }
      setState(() {
        _visitPhase = CustomerVisitPhase.walkingToSeat;
      });
      _walkController.forward(from: 0);
    });
  }

  void _syncVisitIfNeeded() {
    if (_activeVisitIndex != widget.gameState.currentCustomerIndex) {
      setState(() {
        _startVisit();
      });
    }
  }

  void _onWalkStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) {
      return;
    }
    setState(() {
      _visitPhase = CustomerVisitPhase.seatedReadyToOrder;
    });
  }

  void _move(int deltaCol, int deltaRow) {
    setState(() {
      if (deltaCol != 0) {
        _playerNormX = (_playerNormX + deltaCol * _horizontalStep)
            .clamp(_minX, _maxX);
      }
      if (deltaRow != 0) {
        _playerNormY = (_playerNormY + deltaRow * _verticalStep)
            .clamp(_minY, _maxY);
      }
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        _move(0, -1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        _move(0, 1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        _move(-1, 0);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _move(1, 0);
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  Future<void> _openBearistaShop() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => BearistaShopPage(
          player: widget.player,
          gameState: widget.gameState,
        ),
      ),
    );
    _syncVisitIfNeeded();
    setState(() {});
  }

  Future<void> _openShopUpgrades() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ShopUpgradesPage(gameState: widget.gameState),
      ),
    );
    setState(() {});
  }

  String get _talkHint {
    if (_visitPhase != CustomerVisitPhase.seatedReadyToOrder) {
      return 'Wait for ${_currentCustomer.name} to find a seat…';
    }
    return 'Walk closer to ${_currentCustomer.name} to talk';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: _handleKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth =
                    ShopSceneLayout.contentWidthFor(constraints.maxWidth);

                return Column(
                  children: [
                    Center(
                      child: SizedBox(
                        width: contentWidth,
                        child: ShopWorldHeader(
                          title: '${widget.player.displayName}\'s Shop',
                          coins: widget.gameState.coins,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _walkController,
                        builder: (context, child) {
                          final customerPos = _customerPosition;
                          final canTalk = _visitPhase ==
                                  CustomerVisitPhase.seatedReadyToOrder &&
                              _isNearCustomerAt(
                                customerPos.dx,
                                customerPos.dy,
                              );

                          return ShopSceneViewport(
                            child: CartoonShopScene(
                              playerNormX: _playerNormX,
                              playerNormY: _playerNormY,
                              customerNormX: customerPos.dx,
                              customerNormY: customerPos.dy,
                              customerVisitPhase: _visitPhase,
                              customerIsSeated: _customerIsSeated,
                              player: widget.player,
                              customer: _currentCustomer,
                              ownedFurnitureIds:
                                  widget.gameState.ownedFurnitureIds,
                              playerNearCustomer: _isNearCustomerAt(
                                customerPos.dx,
                                customerPos.dy,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _walkController,
                      builder: (context, child) {
                        final customerPos = _customerPosition;
                        final canTalk = _visitPhase ==
                                CustomerVisitPhase.seatedReadyToOrder &&
                            _isNearCustomerAt(customerPos.dx, customerPos.dy);

                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: ShopSceneLayout.controlsMaxWidth,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShopDpad(onMove: _move),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: canTalk
                                          ? FilledButton.icon(
                                              onPressed: _openBearistaShop,
                                              icon: const Icon(
                                                Icons.chat_bubble_outline,
                                              ),
                                              label: const Text('Talk'),
                                            )
                                          : OutlinedButton.icon(
                                              onPressed: null,
                                              icon: const Icon(
                                                Icons.chat_bubble_outline,
                                              ),
                                              label: const Text('Talk'),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _openShopUpgrades,
                                        icon: const Icon(
                                          Icons.storefront_outlined,
                                        ),
                                        label: const Text('Shop Upgrades'),
                                      ),
                                    ),
                                  ],
                                ),
                                if (!canTalk) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _talkHint,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
