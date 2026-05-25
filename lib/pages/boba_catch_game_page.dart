import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/minigame_result.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../services/sound_effects_service.dart';

enum _GamePhase { intro, playing, finished }

class BobaCatchGamePage extends StatefulWidget {
  const BobaCatchGamePage({
    super.key,
    required this.player,
    required this.gameState,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;

  @override
  State<BobaCatchGamePage> createState() => _BobaCatchGamePageState();
}

class _BobaCatchGamePageState extends State<BobaCatchGamePage> {
  static const _gameSeconds = 20;
  static const _maxCoinReward = 15;
  static const _cupWidth = 0.20;
  static const _pearlSize = 0.10;
  static const _catchLine = 0.88;
  static const _cupMoveStep = 0.16;
  static const _playAreaMargin = 0.02;

  static double get _cupMinCenterX => _playAreaMargin + _cupWidth / 2;
  static double get _cupMaxCenterX => 1.0 - _playAreaMargin - _cupWidth / 2;

  final Random _random = Random();

  _GamePhase _phase = _GamePhase.intro;
  int _score = 0;
  int _secondsLeft = _gameSeconds;
  bool _rewardClaimed = false;
  MinigameResult? _result;

  double _cupCenterX = 0.5;
  double? _fallingX;
  double _fallingY = 0;

  Timer? _countdownTimer;
  Timer? _fallTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _fallTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _countdownTimer?.cancel();
    _fallTimer?.cancel();

    setState(() {
      _phase = _GamePhase.playing;
      _score = 0;
      _secondsLeft = _gameSeconds;
      _rewardClaimed = false;
      _result = null;
      _cupCenterX = _cupMinCenterX;
      _spawnPearl();
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

    _fallTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted || _phase != _GamePhase.playing) {
        return;
      }
      setState(() {
        _fallingY += 0.035;
        if (_fallingY >= _catchLine) {
          _resolveCatch();
          _spawnPearl();
        }
      });
    });
  }

  void _spawnPearl() {
    var x = _cupMinCenterX + _random.nextDouble() * (_cupMaxCenterX - _cupMinCenterX);
    for (var attempt = 0; attempt < 8; attempt++) {
      if ((x - _cupCenterX).abs() > _cupWidth) {
        break;
      }
      x = _cupMinCenterX + _random.nextDouble() * (_cupMaxCenterX - _cupMinCenterX);
    }
    _fallingX = x;
    _fallingY = 0.05;
  }

  void _resolveCatch() {
    final pearlX = _fallingX;
    if (pearlX == null) {
      return;
    }
    final halfCatch = (_cupWidth + _pearlSize) / 2;
    if ((pearlX - _cupCenterX).abs() <= halfCatch) {
      _score++;
    }
  }

  void _finishGame() {
    _countdownTimer?.cancel();
    _fallTimer?.cancel();

    if (!_rewardClaimed) {
      final result = MinigameResult.fromBobaCatchScore(_score);
      widget.gameState.coins += result.coinsEarned;
      _rewardClaimed = true;
      _result = result;
      if (result.coinsEarned > 0) {
        SoundEffectsService.instance.playCoinDing();
      }
    }

    setState(() {
      _phase = _GamePhase.finished;
      _fallingX = null;
    });
  }

  void _moveCup(int direction) {
    if (_phase != _GamePhase.playing) {
      return;
    }
    setState(() {
      _cupCenterX =
          (_cupCenterX + direction * _cupMoveStep).clamp(_cupMinCenterX, _cupMaxCenterX);
    });
  }

  void _backToMinigames() {
    Navigator.of(context).pop();
  }

  void _backToCafe() {
    Navigator.of(context)
      ..pop()
      ..pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boba Catch'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8F0),
              Color(0xFFF5E6D3),
              Color(0xFFEDD9C4),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final gameHeight = (constraints.maxHeight * 0.52)
                  .clamp(220.0, 360.0);

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    _ScoreBar(
                      score: _score,
                      secondsLeft: _secondsLeft,
                      coins: widget.gameState.coins,
                      phase: _phase,
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
                                  'Catch falling boba pearls!',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF5C4A42),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Move the cup left and right. '
                                  'Earn 1 coin per catch (max $_maxCoinReward).',
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
                                _ResultPanel(
                                  result: _result ??
                                      MinigameResult.fromBobaCatchScore(_score),
                                  onPlayAgain: _startGame,
                                  onBackToMinigames: _backToMinigames,
                                  onBackToCafe: _backToCafe,
                                ),
                              ] else ...[
                                SizedBox(
                                  height: gameHeight,
                                  child: _GameArea(
                                    cupCenterX: _cupCenterX,
                                    cupWidth: _cupWidth,
                                    pearlX: _fallingX,
                                    pearlY: _fallingY,
                                    pearlSize: _pearlSize,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _CupControls(onMove: _moveCup),
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
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({
    required this.score,
    required this.secondsLeft,
    required this.coins,
    required this.phase,
  });

  final int score;
  final int secondsLeft;
  final int coins;
  final _GamePhase phase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              'Score: $score',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (phase == _GamePhase.playing)
              Text(
                '${secondsLeft}s',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            const SizedBox(width: 16),
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

class _GameArea extends StatelessWidget {
  const _GameArea({
    required this.cupCenterX,
    required this.cupWidth,
    required this.pearlX,
    required this.pearlY,
    required this.pearlSize,
  });

  final double cupCenterX;
  final double cupWidth;
  final double? pearlX;
  final double pearlY;
  final double pearlSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4A574).withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Text(
                    '🧋 Boba Catch!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (width * 0.05).clamp(14.0, 18.0),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5C4A42),
                    ),
                  ),
                ),
                if (pearlX != null)
                  Positioned(
                    left: pearlX! * width - (pearlSize * width) / 2,
                    top: pearlY * height - (pearlSize * width) / 2,
                    child: Container(
                      width: pearlSize * width,
                      height: pearlSize * width,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2914),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: pearlSize * width * 0.35,
                          height: pearlSize * width * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: cupCenterX * width - (cupWidth * width) / 2,
                  bottom: 12,
                  child: _CatchCup(width: cupWidth * width),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CatchCup extends StatelessWidget {
  const _CatchCup({required this.width});

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
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE8A598), Color(0xFFD4897A)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '🥤',
            style: TextStyle(fontSize: width * 0.35),
          ),
        ),
        Container(
          width: width * 0.75,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF5C4A42).withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _CupControls extends StatelessWidget {
  const _CupControls({required this.onMove});

  final void Function(int direction) onMove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.tonalIcon(
          key: const Key('boba_catch_left'),
          onPressed: () => onMove(-1),
          icon: const Icon(Icons.keyboard_arrow_left_rounded),
          label: const Text('Left'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(120, 48),
          ),
        ),
        const SizedBox(width: 16),
        FilledButton.tonalIcon(
          key: const Key('boba_catch_right'),
          onPressed: () => onMove(1),
          icon: const Icon(Icons.keyboard_arrow_right_rounded),
          label: const Text('Right'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(120, 48),
          ),
        ),
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.result,
    required this.onPlayAgain,
    required this.onBackToMinigames,
    required this.onBackToCafe,
  });

  final MinigameResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMinigames;
  final VoidCallback onBackToCafe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Time\'s up!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5C4A42),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Score: ${result.score}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              result.coinsEarned > 0
                  ? '+${result.coinsEarned} coins earned!'
                  : 'No coins this round — try again!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('boba_catch_play_again'),
              onPressed: onPlayAgain,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Play Again'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onBackToMinigames,
              child: const Text('Back to Mini Games'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onBackToCafe,
              child: const Text('Back to Café'),
            ),
          ],
        ),
      ),
    );
  }
}
