import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/starter_customers.dart';
import '../models/active_customer_visit.dart';
import '../models/customer_visit_state.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../widgets/cartoon_shop_scene.dart';
import '../widgets/shop_decoration.dart';
import 'bearista_shop_page.dart';
import 'character_creator_page.dart';
import 'shop_upgrades_page.dart';
import 'store_page.dart';

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
    with TickerProviderStateMixin {
  static const _slotCount = 3;
  static const _horizontalStep = 0.05;
  static const _verticalStep = 0.09;
  static const _talkRangeInSteps = 6.0;
  static const _enterPause = Duration(milliseconds: 400);
  static const _walkDuration = Duration(milliseconds: 1200);
  static const _enterStagger = <Duration>[
    Duration.zero,
    Duration(milliseconds: 550),
    Duration(milliseconds: 1000),
  ];

  static const _minX = RestaurantSceneScale.moveMinX;
  static const _maxX = RestaurantSceneScale.moveMaxX;
  static const _minY = RestaurantSceneScale.moveMinY;
  static const _maxY = RestaurantSceneScale.moveMaxY;

  double _playerNormX = 0.36;
  double _playerNormY = 0.68;

  late List<ActiveCustomerVisit> _visits;
  late List<AnimationController> _walkControllers;
  late List<int> _slotGenerations;

  int _nextReplacementIndex = _slotCount;

  bool _wasOnEntry = false;
  bool _isNavigatingToStore = false;

  /// Walk-path start — clear of entry door, open floor toward counter.
  Listenable get _allWalkAnimations =>
      Listenable.merge(_walkControllers);

  @override
  void initState() {
    super.initState();
    _walkControllers = List.generate(
      _slotCount,
      (_) => AnimationController(vsync: this, duration: _walkDuration),
    );
    _slotGenerations = List.filled(_slotCount, 0);
    _visits = List.generate(_slotCount, (slotIndex) {
      return ActiveCustomerVisit(
        slotIndex: slotIndex,
        customerIndex: slotIndex,
        seat: CustomerSeatingSpot.forSlotIndex(slotIndex),
      );
    });

    for (var slot = 0; slot < _slotCount; slot++) {
      final slotIndex = slot;
      _walkControllers[slotIndex].addStatusListener(
        (status) => _onWalkStatus(slotIndex, status),
      );
      _scheduleVisitStart(slotIndex);
    }
  }

  @override
  void dispose() {
    for (final controller in _walkControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _scheduleVisitStart(int slotIndex) {
    _slotGenerations[slotIndex]++;
    final generation = _slotGenerations[slotIndex];
    final visit = _visits[slotIndex];

    _walkControllers[slotIndex].stop();
    _walkControllers[slotIndex].reset();
    visit.phase = CustomerVisitPhase.waitingToEnter;

    Future<void>.delayed(_enterStagger[slotIndex], () {
      if (!mounted || generation != _slotGenerations[slotIndex]) {
        return;
      }
      setState(() {
        visit.phase = CustomerVisitPhase.entering;
      });

      Future<void>.delayed(_enterPause, () {
        if (!mounted || generation != _slotGenerations[slotIndex]) {
          return;
        }
        setState(() {
          visit.phase = CustomerVisitPhase.walkingToSeat;
        });
        _walkControllers[slotIndex].forward(from: 0);
      });
    });
  }

  void _onWalkStatus(int slotIndex, AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) {
      return;
    }
    setState(() {
      _visits[slotIndex].phase = CustomerVisitPhase.seatedReadyToOrder;
    });
  }

  Offset _positionForVisit(ActiveCustomerVisit visit) {
    if (visit.phase == CustomerVisitPhase.waitingToEnter) {
      return const Offset(
        CustomerSeatingSpot.entryNormX,
        CustomerSeatingSpot.entryNormY,
      );
    }
    if (visit.phase == CustomerVisitPhase.entering) {
      return const Offset(
        CustomerSeatingSpot.entryNormX,
        CustomerSeatingSpot.entryNormY,
      );
    }
    if (visit.phase == CustomerVisitPhase.seatedReadyToOrder) {
      return Offset(visit.seat.normX, visit.seat.normY);
    }

    final t = _walkControllers[visit.slotIndex].value;
    const midX = CustomerSeatingSpot.midAisleNormX;
    const midY = CustomerSeatingSpot.midAisleNormY;
    final seatX = visit.seat.normX;
    final seatY = visit.seat.normY;

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

  double _distanceInSteps(double normX, double normY) {
    final dx = (_playerNormX - normX).abs();
    final dy = (_playerNormY - normY).abs();
    return dx / _horizontalStep + dy / _verticalStep;
  }

  bool _isNear(double normX, double normY) {
    return _distanceInSteps(normX, normY) <= _talkRangeInSteps;
  }

  ActiveCustomerVisit? _nearestTalkTarget() {
    ActiveCustomerVisit? nearest;
    var bestDistance = double.infinity;

    for (final visit in _visits) {
      if (!visit.canTalk) {
        continue;
      }

      final pos = _positionForVisit(visit);
      final distance = _distanceInSteps(pos.dx, pos.dy);
      if (distance > _talkRangeInSteps || distance >= bestDistance) {
        continue;
      }

      bestDistance = distance;
      nearest = visit;
    }

    return nearest;
  }

  List<SceneCustomerDisplay> _sceneCustomers(ActiveCustomerVisit? talkTarget) {
    return _visits
        .where((visit) => visit.phase != CustomerVisitPhase.waitingToEnter)
        .map((visit) {
          final pos = _positionForVisit(visit);
          final isTarget = identical(visit, talkTarget);
          return SceneCustomerDisplay(
            normX: pos.dx,
            normY: pos.dy,
            phase: visit.phase,
            customer: visit.customer,
            isSeated: visit.isSeated,
            showSpeechPrompt: isTarget && visit.canTalk,
          );
        })
        .toList();
  }

  void _replaceVisit(int slotIndex) {
    final visit = _visits[slotIndex];
    visit.customerIndex =
        _nextReplacementIndex % starterCustomers.length;
    _nextReplacementIndex++;
    visit.orderCompleted = false;
    visit.coinReward = null;
    _scheduleVisitStart(slotIndex);
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
    _checkEntryTrigger();
  }

  bool get _isOnEntry => CustomerSeatingSpot.isPlayerOnEntry(
        _playerNormX,
        _playerNormY,
      );

  void _checkEntryTrigger() {
    final onEntry = _isOnEntry;
    if (onEntry && !_wasOnEntry && !_isNavigatingToStore) {
      _openStore();
    }
    _wasOnEntry = onEntry;
  }

  Future<void> _openStore() async {
    _isNavigatingToStore = true;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => StorePage(
          player: widget.player,
          gameState: widget.gameState,
        ),
      ),
    );
    if (mounted) {
      _isNavigatingToStore = false;
      _wasOnEntry = _isOnEntry;
      setState(() {});
    }
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

  Future<void> _openBearistaShop(ActiveCustomerVisit visit) async {
    final completedBefore = visit.orderCompleted;

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => BearistaShopPage(
          player: widget.player,
          gameState: widget.gameState,
          customer: visit.customer,
          orderCompleted: visit.orderCompleted,
          coinReward: visit.coinReward,
          onOrderCompleted: (reward) {
            visit.orderCompleted = true;
            visit.coinReward = reward;
          },
        ),
      ),
    );

    if (visit.orderCompleted && !completedBefore) {
      _replaceVisit(visit.slotIndex);
    }
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

  Future<void> _openCharacterEditor() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => CharacterCreatorPage(
          player: widget.player,
        ),
      ),
    );
    setState(() {});
  }

  String _talkHint(ActiveCustomerVisit? talkTarget) {
    final anyStillWalking = _visits.any(
      (visit) =>
          visit.phase == CustomerVisitPhase.entering ||
          visit.phase == CustomerVisitPhase.walkingToSeat ||
          visit.phase == CustomerVisitPhase.waitingToEnter,
    );
    final anySeatedReady = _visits.any((visit) => visit.canTalk);

    if (talkTarget != null) {
      return 'Walk closer to ${talkTarget.customer.name} to talk';
    }
    if (anyStillWalking && !anySeatedReady) {
      return 'Wait for customers to find their seats…';
    }
    if (anySeatedReady) {
      return 'Walk closer to a seated customer to talk';
    }
    return 'Wait for customers to find their seats…';
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
                        animation: _allWalkAnimations,
                        builder: (context, child) {
                          final talkTarget = _nearestTalkTarget();
                          return ShopSceneViewport(
                            child: CartoonShopScene(
                              playerNormX: _playerNormX,
                              playerNormY: _playerNormY,
                              customers: _sceneCustomers(talkTarget),
                              player: widget.player,
                              ownedFurnitureIds:
                                  widget.gameState.ownedFurnitureIds,
                              onPlayerTap: _openCharacterEditor,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _allWalkAnimations,
                      builder: (context, child) {
                        final talkTarget = _nearestTalkTarget();
                        final canTalk = talkTarget != null &&
                            _isNear(
                              _positionForVisit(talkTarget).dx,
                              _positionForVisit(talkTarget).dy,
                            );

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
                                              onPressed: () =>
                                                  _openBearistaShop(talkTarget),
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
                                    _talkHint(talkTarget),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  'Tap your bear to customize',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.45),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
