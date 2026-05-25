import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/minigame_result.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../services/sound_effects_service.dart';
import '../widgets/cute_bear_avatar.dart';
import '../widgets/minigame_common.dart';

enum _GamePhase { intro, playing, finished }

class BobaStackGamePage extends StatefulWidget {
  const BobaStackGamePage({
    super.key,
    required this.player,
    required this.gameState,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;

  @override
  State<BobaStackGamePage> createState() => _BobaStackGamePageState();
}

class _BobaStackGamePageState extends State<BobaStackGamePage>
    with TickerProviderStateMixin {
  static const _gameSeconds = 20;
  static const _maxTries = 3;
  static const _stackZoneCenter = 0.5;
  static const _judgeWindow = 0.048;
  static const _cupSpawnX = 0.14;
  static const _slideTickMs = 50;
  static const _cupSpeedMin = 0.032;
  static const _cupSpeedMax = 0.048;
  static const _minTravelBeforeJudge = 0.30;
  static const _nextCupDelayMs = 320;

  final Random _random = Random();

  _GamePhase _phase = _GamePhase.intro;
  int _cupsStacked = 0;
  int _triesLeft = _maxTries;
  int _secondsLeft = _gameSeconds;
  bool _rewardClaimed = false;
  MinigameResult? _result;
  String? _feedbackMessage;

  late AnimationController _jumpController;

  Timer? _countdownTimer;
  Timer? _slideTimer;

  bool _cupActive = false;
  bool _cupJudged = false;
  bool _fromLeft = true;
  double _slidingCupX = -0.12;
  double _cupSlideSpeed = 0.02;
  double _cupSpawnXPos = -0.14;
  int _slideTickCount = 0;
  int _spawnAfterTick = -1;

  @override
  void initState() {
    super.initState();
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    )..addListener(() {
        if (mounted && _phase == _GamePhase.playing) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _slideTimer?.cancel();
    _jumpController.dispose();
    super.dispose();
  }

  bool get _isAirborne =>
      _jumpController.isAnimating &&
      _jumpController.value > 0.18 &&
      _jumpController.value < 0.82;

  double get _jumpOffset => sin(pi * _jumpController.value) * 42;

  double _pickCupSlideSpeed() {
    final stackBonus = min(_cupsStacked * 0.002, 0.006);
    final minSpeed = _cupSpeedMin + stackBonus;
    final maxSpeed = _cupSpeedMax + stackBonus;
    final rangeMilli = max(((maxSpeed - minSpeed) * 1000).round(), 1);
    return minSpeed + _random.nextInt(rangeMilli + 1) / 1000;
  }

  bool _cupEnteredStackZone(double previousX, double currentX) {
    final zoneMin = _stackZoneCenter - _judgeWindow;
    final zoneMax = _stackZoneCenter + _judgeWindow;
    final wasOutsideZone = previousX < zoneMin || previousX > zoneMax;
    if (!wasOutsideZone) {
      return false;
    }
    final minX = min(previousX, currentX);
    final maxX = max(previousX, currentX);
    return maxX >= zoneMin && minX <= zoneMax;
  }

  void _startGame() {
    _countdownTimer?.cancel();
    _slideTimer?.cancel();
    _jumpController.reset();

    setState(() {
      _phase = _GamePhase.playing;
      _cupsStacked = 0;
      _triesLeft = _maxTries;
      _secondsLeft = _gameSeconds;
      _rewardClaimed = false;
      _result = null;
      _feedbackMessage = null;
      _cupActive = false;
      _cupJudged = false;
      _fromLeft = true;
      _slideTickCount = 0;
      _spawnAfterTick = -1;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _phase != _GamePhase.playing) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsLeft--;
      });
      if (_secondsLeft <= 0) {
        _finishGame();
      }
    });

    _slideTimer = Timer.periodic(const Duration(milliseconds: _slideTickMs), (_) {
      _onSlideTick();
    });

    _scheduleNextCup(delay: const Duration(milliseconds: 450));
  }

  void _scheduleNextCup({Duration delay = const Duration(milliseconds: _nextCupDelayMs)}) {
    if (_phase != _GamePhase.playing || _triesLeft <= 0) {
      return;
    }
    final ticksToWait = max(1, (delay.inMilliseconds / _slideTickMs).ceil());
    _spawnAfterTick = _slideTickCount + ticksToWait;
  }

  void _maybeSpawnScheduledCup() {
    if (_spawnAfterTick < 0 ||
        _slideTickCount < _spawnAfterTick ||
        _cupActive ||
        _phase != _GamePhase.playing ||
        _triesLeft <= 0) {
      return;
    }
    _spawnAfterTick = -1;
    _spawnCup();
  }

  void _spawnCup() {
    if (_phase != _GamePhase.playing || _triesLeft <= 0 || _cupActive) {
      return;
    }
    final fromLeft = _cupsStacked.isEven ? _random.nextBool() : !_fromLeft;
    final startX = fromLeft ? -_cupSpawnX : 1 + _cupSpawnX;
    setState(() {
      _fromLeft = fromLeft;
      _slidingCupX = startX;
      _cupSpawnXPos = startX;
      _cupSlideSpeed = _pickCupSlideSpeed();
      _cupActive = true;
      _cupJudged = false;
      _feedbackMessage = null;
    });
  }

  void _resolveSuccess() {
    if (_cupJudged) {
      return;
    }
    _cupJudged = true;
    _cupActive = false;
    setState(() {
      _cupsStacked++;
      _feedbackMessage = 'Nice stack! 🧋';
    });
    _scheduleNextCup();
  }

  void _resolveMiss(String message) {
    if (_cupJudged) {
      return;
    }
    _cupJudged = true;
    _cupActive = false;
    setState(() {
      _feedbackMessage = message;
      _triesLeft--;
    });
    if (_triesLeft <= 0) {
      _finishGame();
      return;
    }
    _scheduleNextCup(delay: const Duration(milliseconds: 400));
  }

  void _onSlideTick() {
    if (!mounted || _phase != _GamePhase.playing) {
      return;
    }

    _slideTickCount++;
    _maybeSpawnScheduledCup();

    if (!_cupActive || _cupJudged) {
      return;
    }

    final previousX = _slidingCupX;
    setState(() {
      _slidingCupX += _fromLeft ? _cupSlideSpeed : -_cupSlideSpeed;
    });

    if ((_slidingCupX - _cupSpawnXPos).abs() >= _minTravelBeforeJudge &&
        _cupEnteredStackZone(previousX, _slidingCupX)) {
      if (_isAirborne) {
        _resolveSuccess();
      } else {
        _resolveMiss('Miss! Jump when the cup slides under you.');
      }
      return;
    }

    final offScreen = _fromLeft
        ? _slidingCupX > 1 + _cupSpawnX
        : _slidingCupX < -_cupSpawnX;
    if (offScreen) {
      _resolveMiss('Too slow! Jump as the cup passes by.');
    }
  }

  void _jump() {
    if (_phase != _GamePhase.playing || _jumpController.isAnimating) {
      return;
    }
    _jumpController.forward(from: 0).whenComplete(() {
      if (mounted) {
        _jumpController.value = 0;
      }
    });
  }

  void _finishGame() {
    _countdownTimer?.cancel();
    _slideTimer?.cancel();
    _jumpController.stop();

    if (!_rewardClaimed) {
      final result = MinigameResult.fromBobaStackScore(_cupsStacked);
      widget.gameState.coins += result.coinsEarned;
      _rewardClaimed = true;
      _result = result;
      if (result.coinsEarned > 0) {
        SoundEffectsService.instance.playCoinDing();
      }
    }

    setState(() {
      _phase = _GamePhase.finished;
      _cupActive = false;
    });
  }

  String _funMessage() {
    if (_cupsStacked >= 12) {
      return 'Tower master! 🏆';
    }
    if (_cupsStacked >= 6) {
      return 'Great stacking! ✨';
    }
    if (_cupsStacked >= 1) {
      return 'Keep practicing your jumps! 🐻';
    }
    return 'Try again — timing is everything! 💪';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MinigamePageShell(
      title: 'Boba Stack',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gameHeight = (constraints.maxHeight * 0.48).clamp(220.0, 360.0);

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                _StackScoreBar(
                  cupsStacked: _cupsStacked,
                  triesLeft: _triesLeft,
                  maxTries: _maxTries,
                  secondsLeft: _secondsLeft,
                  coins: widget.gameState.coins,
                  showTimer: _phase == _GamePhase.playing,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_phase == _GamePhase.intro) ...[
                            Text(
                              'Jump to stack sliding boba cups!',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF5C4A42),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cups slide in from the sides. Jump at the right moment '
                              'so they slide under you and stack up. '
                              'Earn 1 coin per 2 cups (max ${MinigameResult.maxCoinReward}).',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: _startGame,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Start Game'),
                            ),
                          ] else if (_phase == _GamePhase.finished) ...[
                            MinigameResultPanel(
                              result: _result ??
                                  MinigameResult.fromBobaStackScore(_cupsStacked),
                              scoreTitle:
                                  'Cups stacked: $_cupsStacked\n${_funMessage()}',
                              onPlayAgain: _startGame,
                              onBackToMinigames: () => Navigator.of(context).pop(),
                              onBackToCafe: () => popBackToCafe(context),
                              playAgainKey: const Key('boba_stack_play_again'),
                            ),
                          ] else ...[
                            SizedBox(
                              height: gameHeight,
                              child: _JumpStackArena(
                                player: widget.player,
                                cupsStacked: _cupsStacked,
                                jumpOffset: _jumpOffset,
                                slidingCupX: _slidingCupX,
                                cupActive: _cupActive,
                                fromLeft: _fromLeft,
                                feedbackMessage: _feedbackMessage,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              key: const Key('boba_stack_jump'),
                              onPressed: _jump,
                              icon: const Icon(Icons.arrow_upward_rounded),
                              label: const Text('Jump'),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(180, 52),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StackScoreBar extends StatelessWidget {
  const _StackScoreBar({
    required this.cupsStacked,
    required this.triesLeft,
    required this.maxTries,
    required this.secondsLeft,
    required this.coins,
    required this.showTimer,
  });

  final int cupsStacked;
  final int triesLeft;
  final int maxTries;
  final int secondsLeft;
  final int coins;
  final bool showTimer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              'Cups: $cupsStacked',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              List.generate(
                maxTries,
                (i) => i < triesLeft ? '❤️' : '🖤',
              ).join(),
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            if (showTimer)
              Text(
                '${secondsLeft}s',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            if (showTimer) const SizedBox(width: 12),
            Text(
              '🪙 $coins',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JumpStackArena extends StatelessWidget {
  const _JumpStackArena({
    required this.player,
    required this.cupsStacked,
    required this.jumpOffset,
    required this.slidingCupX,
    required this.cupActive,
    required this.fromLeft,
    required this.feedbackMessage,
  });

  final PlayerCharacter player;
  final int cupsStacked;
  final double jumpOffset;
  final double slidingCupX;
  final bool cupActive;
  final bool fromLeft;
  final String? feedbackMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4A574).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                Text(
                  '🥛 Boba Stack',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C4A42),
                      ),
                ),
                const Spacer(),
                if (cupActive)
                  Text(
                    fromLeft ? '← Cup incoming' : 'Cup incoming →',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF5C4A42).withValues(alpha: 0.65),
                        ),
                  ),
              ],
            ),
          ),
          if (feedbackMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12, right: 12),
              child: Text(
                feedbackMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: feedbackMessage!.contains('Nice')
                          ? const Color(0xFF5C8A4A)
                          : const Color(0xFFB85C5C),
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                const stackBaseBottom = 16.0;
                const maxVisibleCups = 12;
                final hiddenCount = max(0, cupsStacked - maxVisibleCups);
                final visibleCount = min(cupsStacked, maxVisibleCups);
                final cupWidth = (width * 0.20).clamp(40.0, 64.0);
                final cupHeight = cupWidth * 0.55;
                final cupStep = cupHeight * 0.82;
                final maxTowerHeight = height * 0.58;
                final towerHeight = visibleCount * cupStep;
                final effectiveStep = towerHeight > maxTowerHeight && visibleCount > 0
                    ? maxTowerHeight / visibleCount
                    : cupStep;
                final stackTopBottom = stackBaseBottom + visibleCount * effectiveStep;
                final playerSeatOffset = cupHeight * 0.38;
                final playerBottom =
                    stackTopBottom + playerSeatOffset + jumpOffset;
                final incomingCupBottom =
                    stackBaseBottom + (visibleCount + 1) * effectiveStep;
                final playerSize = (width * 0.18).clamp(44.0, 58.0);

                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      left: width * 0.5 - 1,
                      top: height * 0.12,
                      bottom: stackBaseBottom,
                      child: Container(
                        width: 2,
                        color: const Color(0xFFE8A598).withValues(alpha: 0.35),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: width * 0.22,
                      right: width * 0.22,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C4A42).withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: stackBaseBottom,
                      left: width * 0.5 - cupWidth / 2,
                      child: _StackCupWidget(size: cupWidth, highlight: false),
                    ),
                    for (var i = 0; i < visibleCount; i++)
                      Positioned(
                        bottom: stackBaseBottom + (i + 1) * effectiveStep,
                        left: width * 0.5 - cupWidth / 2,
                        child: _StackCupWidget(size: cupWidth, highlight: false),
                      ),
                    if (cupActive)
                      Positioned(
                        left: slidingCupX * width - cupWidth / 2,
                        bottom: incomingCupBottom,
                        child: _StackCupWidget(size: cupWidth, highlight: true),
                      ),
                    Positioned(
                      bottom: playerBottom,
                      left: width * 0.5 - playerSize / 2,
                      child: PlayerBearAvatar(
                        player: player,
                        size: playerSize,
                      ),
                    ),
                    if (hiddenCount > 0)
                      Positioned(
                        bottom: stackBaseBottom + effectiveStep * 0.35,
                        left: width * 0.5 + cupWidth * 0.55,
                        child: Text(
                          '+$hiddenCount',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF5C4A42).withValues(alpha: 0.7),
                              ),
                        ),
                      ),
                    if (cupsStacked == 0 && !cupActive)
                      Positioned(
                        bottom: height * 0.35,
                        left: 0,
                        right: 0,
                        child: Text(
                          'Get ready to jump…',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF5C4A42).withValues(alpha: 0.5),
                              ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StackCupWidget extends StatelessWidget {
  const _StackCupWidget({
    required this.size,
    required this.highlight,
  });

  final double size;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: highlight
              ? [const Color(0xFFF5C6D6), const Color(0xFFE8A598)]
              : [const Color(0xFFE8A598), const Color(0xFFD4897A)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight
              ? Colors.white
              : Colors.white.withValues(alpha: 0.7),
          width: highlight ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: highlight ? 0.2 : 0.12),
            blurRadius: highlight ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text('🥤', style: TextStyle(fontSize: size * 0.32)),
    );
  }
}
