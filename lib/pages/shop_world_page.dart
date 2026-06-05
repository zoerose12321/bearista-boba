import 'dart:async';
import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/starter_customers.dart';
import '../models/active_customer_visit.dart';
import '../models/seating_assignment.dart';
import '../models/control_style.dart';
import '../models/customer_visit_state.dart';
import '../models/helper_npc_state.dart';
import '../models/local_multiplayer_state.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../services/coin_reward_service.dart';
import '../services/helper_npc_service.dart';
import '../services/sound_effects_service.dart';
import '../widgets/ad_placeholder_bar.dart';
import '../widgets/cartoon_shop_scene.dart';
import '../widgets/joy_con_control.dart';
import '../widgets/movement_controls.dart';
import '../widgets/multiplayer_panel.dart';
import '../widgets/shop_decoration.dart';
import 'bearista_shop_page.dart';
import 'character_creator_page.dart';
import 'minigames_page.dart';
import 'shop_upgrades_page.dart';
import 'store_page.dart';

class ShopWorldPage extends StatefulWidget {
  const ShopWorldPage({
    super.key,
    required this.player,
    required this.gameState,
    this.controlStyle = ControlStyle.arrows,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;
  final ControlStyle controlStyle;

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
  final Random _customerRandom = Random();

  bool _wasOnEntry = false;
  bool _isNavigatingToStore = false;
  bool _multiplayerPanelOpen = false;
  final LocalMultiplayerState _localMultiplayer = LocalMultiplayerState();
  final HelperNpcState _helperNpc = HelperNpcState();
  Timer? _helperNpcTimer;
  Timer? _helperWorkTimer;
  int? _playerTalkSlotIndex;

  final GlobalKey<JoyConControlState> _joyConKey = GlobalKey<JoyConControlState>();
  Timer? _joyConMoveTimer;
  int _joyConDeltaCol = 0;
  int _joyConDeltaRow = 0;
  static const _joyConMoveInterval = Duration(milliseconds: 150);
  static const _joyConStepScale = 0.75;

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
    final initialSeats = SeatingAssignment.pickUniqueSpots(_slotCount);
    _visits = List.generate(_slotCount, (slotIndex) {
      return ActiveCustomerVisit(
        slotIndex: slotIndex,
        customerId: starterCustomers[slotIndex].id,
        seat: initialSeats[slotIndex],
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
    _stopJoyConMovement(resetKnob: false);
    _stopHelperNpc();
    for (final controller in _walkControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onJoyConDirection(int deltaCol, int deltaRow) {
    if (deltaCol == 0 && deltaRow == 0) {
      _stopJoyConMovement();
      return;
    }

    _joyConDeltaCol = deltaCol;
    _joyConDeltaRow = deltaRow;

    if (_joyConMoveTimer != null) {
      return;
    }

    _moveJoyCon(deltaCol, deltaRow);
    _joyConMoveTimer = Timer.periodic(_joyConMoveInterval, (_) {
      if (!mounted) {
        _stopJoyConMovement(resetKnob: false);
        return;
      }
      if (_joyConDeltaCol == 0 && _joyConDeltaRow == 0) {
        _stopJoyConMovement();
        return;
      }
      _moveJoyCon(_joyConDeltaCol, _joyConDeltaRow);
    });
  }

  void _stopJoyConMovement({bool resetKnob = true}) {
    _joyConMoveTimer?.cancel();
    _joyConMoveTimer = null;
    _joyConDeltaCol = 0;
    _joyConDeltaRow = 0;
    if (resetKnob) {
      _joyConKey.currentState?.resetKnob();
    }
  }

  void _pauseJoyConForNavigation() {
    _stopJoyConMovement();
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
    return _distanceBetween(_playerNormX, _playerNormY, normX, normY);
  }

  double _distanceBetween(
    double fromX,
    double fromY,
    double toX,
    double toY,
  ) {
    final dx = (fromX - toX).abs();
    final dy = (fromY - toY).abs();
    return dx / _horizontalStep + dy / _verticalStep;
  }

  String? _helperSpeechBubble() {
    if (!_localMultiplayer.isFriendHelperActive) {
      return null;
    }
    final message = _helperNpc.statusMessage;
    return message.isEmpty ? null : message;
  }

  bool _visitBlockedByHelper(ActiveCustomerVisit visit) {
    return _helperNpc.isHandlingSlot(visit.slotIndex);
  }

  double _visitNormX(ActiveCustomerVisit visit) =>
      _positionForVisit(visit).dx;

  double _visitNormY(ActiveCustomerVisit visit) =>
      _positionForVisit(visit).dy;

  void _startLocalCafe() {
    setState(() {
      _localMultiplayer.startLocalCafe();
    });
  }

  void _addFriendHelper() {
    setState(() {
      _localMultiplayer.addFriendHelper(
        playerNormX: _playerNormX,
        playerNormY: _playerNormY,
        minX: _minX,
        maxX: _maxX,
        minY: _minY,
        maxY: _maxY,
      );
      _helperNpc.activateIdle();
    });
    _startHelperNpcLoop();
  }

  void _endMultiplayer() {
    _stopHelperNpc();
    setState(() {
      _localMultiplayer.endMultiplayer();
    });
  }

  void _startHelperNpcLoop() {
    _helperNpcTimer?.cancel();
    if (!_localMultiplayer.isFriendHelperActive) {
      return;
    }
    _helperNpcTimer = Timer.periodic(
      const Duration(milliseconds: 120),
      (_) => _tickHelperNpc(),
    );
  }

  void _pauseHelperNpc() {
    _helperNpcTimer?.cancel();
    _helperNpcTimer = null;
    _helperWorkTimer?.cancel();
    _helperWorkTimer = null;
    if (_localMultiplayer.isFriendHelperActive &&
        _helperNpc.phase != HelperNpcPhase.inactive) {
      _helperNpc.phase = HelperNpcPhase.idle;
      _helperNpc.targetSlotIndex = null;
      _helperNpc.statusMessage = 'Looking for orders…';
    }
  }

  void _stopHelperNpc() {
    _pauseHelperNpc();
    _helperNpc.reset();
    _playerTalkSlotIndex = null;
  }

  void _resumeHelperNpc() {
    if (!_localMultiplayer.isFriendHelperActive) {
      return;
    }
    if (_helperNpc.phase == HelperNpcPhase.inactive) {
      _helperNpc.activateIdle();
    }
    _startHelperNpcLoop();
  }

  void _tickHelperNpc() {
    if (!mounted || !_localMultiplayer.isFriendHelperActive) {
      return;
    }

    if (_helperNpc.phase == HelperNpcPhase.idle) {
      if (_helperWorkTimer?.isActive ?? false) {
        return;
      }

      final visit = HelperNpcService.pickReadyVisit(
        visits: _visits,
        helper: _helperNpc,
        playerTalkSlot: _playerTalkSlotIndex,
        helperNormX: _localMultiplayer.friendNormX,
        helperNormY: _localMultiplayer.friendNormY,
        visitNormX: _visitNormX,
        visitNormY: _visitNormY,
        horizontalStep: _horizontalStep,
        verticalStep: _verticalStep,
      );

      if (visit == null) {
        if (_helperNpc.statusMessage.isEmpty) {
          setState(() {
            _helperNpc.statusMessage = 'Looking for orders…';
          });
        }
        return;
      }

      final customerPos = _positionForVisit(visit);
      setState(() {
        _helperNpc.targetSlotIndex = visit.slotIndex;
        _helperNpc.targetNormX = (customerPos.dx + HelperNpcService.standOffsetX)
            .clamp(_minX, _maxX);
        _helperNpc.targetNormY = (customerPos.dy + HelperNpcService.standOffsetY)
            .clamp(_minY, _maxY);
        _helperNpc.phase = HelperNpcPhase.walkingToCustomer;
        _helperNpc.statusMessage = "I'll help!";
      });
      return;
    }

    if (_helperNpc.phase == HelperNpcPhase.walkingToCustomer) {
      if (HelperNpcService.isNearTarget(
        helperNormX: _localMultiplayer.friendNormX,
        helperNormY: _localMultiplayer.friendNormY,
        targetNormX: _helperNpc.targetNormX,
        targetNormY: _helperNpc.targetNormY,
        horizontalStep: _horizontalStep,
        verticalStep: _verticalStep,
      )) {
        _beginHelperOrderWork();
        return;
      }

      final step = HelperNpcService.stepToward(
        fromX: _localMultiplayer.friendNormX,
        fromY: _localMultiplayer.friendNormY,
        toX: _helperNpc.targetNormX,
        toY: _helperNpc.targetNormY,
        horizontalStep: _horizontalStep,
        verticalStep: _verticalStep,
        minX: _minX,
        maxX: _maxX,
        minY: _minY,
        maxY: _maxY,
      );
      setState(() {
        _localMultiplayer.friendNormX = step.x;
        _localMultiplayer.friendNormY = step.y;
      });
    }
  }

  void _beginHelperOrderWork() {
    _helperNpcTimer?.cancel();
    _helperNpcTimer = null;

    setState(() {
      _helperNpc.phase = HelperNpcPhase.takingOrder;
      _helperNpc.statusMessage = 'Taking order…';
    });

    _helperWorkTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted || !_localMultiplayer.isFriendHelperActive) {
        return;
      }
      setState(() {
        _helperNpc.phase = HelperNpcPhase.makingDrink;
        _helperNpc.statusMessage = 'Making drink…';
      });

      _helperWorkTimer = Timer(const Duration(milliseconds: 2200), () {
        if (!mounted || !_localMultiplayer.isFriendHelperActive) {
          return;
        }
        setState(() {
          _helperNpc.phase = HelperNpcPhase.servingDrink;
          _helperNpc.statusMessage = 'Serving drink…';
        });

        _helperWorkTimer = Timer(const Duration(milliseconds: 500), () {
          if (!mounted || !_localMultiplayer.isFriendHelperActive) {
            return;
          }
          _completeHelperOrder();
        });
      });
    });
  }

  void _completeHelperOrder() {
    final slotIndex = _helperNpc.targetSlotIndex;
    if (slotIndex == null) {
      _helperNpc.activateIdle();
      _startHelperNpcLoop();
      return;
    }

    final visit = _visits[slotIndex];
    if (!visit.canTalk) {
      setState(() {
        _helperNpc.activateIdle();
      });
      _startHelperNpcLoop();
      return;
    }

    final reward = CoinRewardService.rollReward();
    visit.orderCompleted = true;
    visit.coinReward = reward;
    widget.gameState.coins += reward;
    SoundEffectsService.instance.playCoinDing();

    setState(() {
      _helperNpc.statusMessage = 'Served! +$reward';
    });

    _replaceVisit(slotIndex);

    _helperWorkTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted || !_localMultiplayer.isFriendHelperActive) {
        return;
      }
      setState(() {
        _helperNpc.activateIdle();
      });
      _startHelperNpcLoop();
    });
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
      if (_visitBlockedByHelper(visit)) {
        continue;
      }
      if (_playerTalkSlotIndex == visit.slotIndex) {
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
          final customer = visit.customer(widget.gameState);
          return SceneCustomerDisplay(
            normX: pos.dx,
            normY: pos.dy,
            phase: visit.phase,
            customer: customer,
            isSeated: visit.isSeated,
            showSpeechPrompt: isTarget && visit.canTalk,
          );
        })
        .toList();
  }

  String _pickReplacementCustomerId({required int excludingSlot}) {
    final activeIds = <String>{};
    for (var i = 0; i < _visits.length; i++) {
      if (i == excludingSlot) {
        continue;
      }
      final other = _visits[i];
      if (other.phase == CustomerVisitPhase.waitingToEnter) {
        continue;
      }
      activeIds.add(other.customerId);
    }

    final candidates = widget.gameState.customerPool
        .where((customer) => !activeIds.contains(customer.id))
        .toList();
    if (candidates.isEmpty) {
      final fallback =
          starterCustomers[_nextReplacementIndex % starterCustomers.length];
      _nextReplacementIndex++;
      return fallback.id;
    }

    _nextReplacementIndex++;
    return candidates[_customerRandom.nextInt(candidates.length)].id;
  }

  void _replaceVisit(int slotIndex) {
    final visit = _visits[slotIndex];
    visit.customerId = _pickReplacementCustomerId(excludingSlot: slotIndex);
    visit.orderCompleted = false;
    visit.coinReward = null;
    _assignRandomSeat(slotIndex);
    _scheduleVisitStart(slotIndex);
  }

  void _assignRandomSeat(int slotIndex) {
    final occupied = <String>{};
    for (var i = 0; i < _visits.length; i++) {
      if (i == slotIndex) {
        continue;
      }
      final other = _visits[i];
      if (other.phase == CustomerVisitPhase.waitingToEnter) {
        continue;
      }
      occupied.add(other.seat.id);
    }

    _visits[slotIndex].seat = SeatingAssignment.pickOpenSpot(
      occupied,
      fallback: _visits[slotIndex].seat,
    );
  }

  void _move(int deltaCol, int deltaRow) {
    _applyMove(deltaCol, deltaRow, stepScale: 1.0);
  }

  void _moveJoyCon(int deltaCol, int deltaRow) {
    _applyMove(deltaCol, deltaRow, stepScale: _joyConStepScale);
  }

  void _applyMove(int deltaCol, int deltaRow, {required double stepScale}) {
    setState(() {
      if (deltaCol != 0) {
        _playerNormX = (_playerNormX + deltaCol * _horizontalStep * stepScale)
            .clamp(_minX, _maxX);
      }
      if (deltaRow != 0) {
        _playerNormY = (_playerNormY + deltaRow * _verticalStep * stepScale)
            .clamp(_minY, _maxY);
      }
    });
    _checkEntryTrigger();
  }

  bool get _isOnEntry => CustomerSeatingSpot.isPlayerOnEntry(
        _playerNormX,
        _playerNormY,
      );

  bool get _canPlayMinigames => CafeMinigameCorner.isPlayerNear(
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
    _pauseJoyConForNavigation();
    _pauseHelperNpc();
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
      _resumeHelperNpc();
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
    _pauseJoyConForNavigation();
    _pauseHelperNpc();
    _playerTalkSlotIndex = visit.slotIndex;
    final completedBefore = visit.orderCompleted;

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => BearistaShopPage(
          player: widget.player,
          gameState: widget.gameState,
          customer: visit.customer(widget.gameState),
          orderCompleted: visit.orderCompleted,
          coinReward: visit.coinReward,
          onOrderCompleted: (reward) {
            visit.orderCompleted = true;
            visit.coinReward = reward;
          },
        ),
      ),
    );

    _playerTalkSlotIndex = null;
    if (visit.orderCompleted && !completedBefore) {
      _replaceVisit(visit.slotIndex);
    }
    _resumeHelperNpc();
    setState(() {});
  }

  Future<void> _openMinigames() async {
    _pauseJoyConForNavigation();
    _pauseHelperNpc();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => MinigamesPage(
          player: widget.player,
          gameState: widget.gameState,
        ),
      ),
    );
    if (mounted) {
      _resumeHelperNpc();
      setState(() {});
    }
  }

  Future<void> _openShopUpgrades() async {
    _pauseJoyConForNavigation();
    _pauseHelperNpc();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ShopUpgradesPage(gameState: widget.gameState),
      ),
    );
    _resumeHelperNpc();
    setState(() {});
  }

  Future<void> _openCharacterEditor() async {
    _pauseJoyConForNavigation();
    _pauseHelperNpc();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => CharacterCreatorPage(
          player: widget.player,
        ),
      ),
    );
    _resumeHelperNpc();
    setState(() {});
  }

  void _toggleMultiplayerPanel() {
    setState(() {
      _multiplayerPanelOpen = !_multiplayerPanelOpen;
    });
  }

  void _closeMultiplayerPanel() {
    if (!_multiplayerPanelOpen) {
      return;
    }
    setState(() {
      _multiplayerPanelOpen = false;
    });
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
      return 'Walk closer to ${talkTarget.customer(widget.gameState).name} to talk';
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
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const panelBesideMinWidth = 720.0;
                      final showPanelBeside = _multiplayerPanelOpen &&
                          constraints.maxWidth >= panelBesideMinWidth;
                      final panelWidth = (constraints.maxWidth * 0.3)
                          .clamp(280.0, 360.0);
                      final cafeAreaWidth = showPanelBeside
                          ? constraints.maxWidth - panelWidth - 12
                          : constraints.maxWidth;
                      final contentWidth =
                          ShopSceneLayout.contentWidthFor(cafeAreaWidth);

                      Widget buildControls() {
                        return AnimatedBuilder(
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
                                    MovementControls(
                                      style: widget.controlStyle,
                                      onMove: _move,
                                      onJoyConDirection: _onJoyConDirection,
                                      joyConKey: _joyConKey,
                                    ),
                                    const SizedBox(height: 12),
                                    if (_canPlayMinigames) ...[
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton.icon(
                                          key: const Key('play_minigames'),
                                          onPressed: _openMinigames,
                                          icon: const Icon(
                                            Icons.sports_esports_outlined,
                                          ),
                                          label: const Text('Play Minigames'),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                    Row(
                                      children: [
                                        Expanded(
                                          child: canTalk
                                              ? FilledButton.icon(
                                                  onPressed: () =>
                                                      _openBearistaShop(
                                                        talkTarget,
                                                      ),
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
                                      const SizedBox(height: 6),
                                      Text(
                                        _talkHint(talkTarget),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tap your bear to customize',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
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
                        );
                      }

                      final cafeColumn = Column(
                        children: [
                          Center(
                            child: SizedBox(
                              width: contentWidth,
                              child: ShopWorldHeader(
                                title: '${widget.player.displayName}\'s Shop',
                                coins: widget.gameState.coins,
                                onMultiplayerPressed: _toggleMultiplayerPanel,
                                multiplayerActive: _multiplayerPanelOpen,
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
                                    showFriendHelper:
                                        _localMultiplayer.isFriendHelperActive,
                                    friendNormX: _localMultiplayer.friendNormX,
                                    friendNormY: _localMultiplayer.friendNormY,
                                    friendHelperSpeech: _helperSpeechBubble(),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (_multiplayerPanelOpen && !showPanelBeside) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              height: (constraints.maxHeight * 0.34)
                                  .clamp(220.0, 300.0),
                              child: MultiplayerPanel(
                                player: widget.player,
                                gameState: widget.gameState,
                                multiplayerState: _localMultiplayer,
                                onClose: _closeMultiplayerPanel,
                                onStartLocalCafe: _startLocalCafe,
                                onAddFriendHelper: _addFriendHelper,
                                onEndMultiplayer: _endMultiplayer,
                                compact: true,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          buildControls(),
                        ],
                      );

                      if (showPanelBeside) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: cafeColumn),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: panelWidth,
                              child: MultiplayerPanel(
                                player: widget.player,
                                gameState: widget.gameState,
                                multiplayerState: _localMultiplayer,
                                onClose: _closeMultiplayerPanel,
                                onStartLocalCafe: _startLocalCafe,
                                onAddFriendHelper: _addFriendHelper,
                                onEndMultiplayer: _endMultiplayer,
                                compact: true,
                              ),
                            ),
                          ],
                        );
                      }

                      return cafeColumn;
                    },
                  ),
                ),
              ),
            ),
            // Reserved bottom banner slot — replace [AdPlaceholderBar] with ad widget later.
            const AdPlaceholderBar(),
          ],
        ),
      ),
    );
  }
}
