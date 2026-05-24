import 'dart:async';

import 'package:flutter/material.dart';

import '../models/minigame_result.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../services/sound_effects_service.dart';
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

class _BobaStackGamePageState extends State<BobaStackGamePage> {
  static const _gameSeconds = 20;

  _GamePhase _phase = _GamePhase.intro;
  int _cupsStacked = 0;
  int _secondsLeft = _gameSeconds;
  bool _rewardClaimed = false;
  MinigameResult? _result;

  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _countdownTimer?.cancel();

    setState(() {
      _phase = _GamePhase.playing;
      _cupsStacked = 0;
      _secondsLeft = _gameSeconds;
      _rewardClaimed = false;
      _result = null;
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
  }

  void _stackCup() {
    if (_phase != _GamePhase.playing) {
      return;
    }
    setState(() {
      _cupsStacked++;
    });
  }

  void _finishGame() {
    _countdownTimer?.cancel();

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MinigamePageShell(
      title: 'Boba Stack',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackHeight = (constraints.maxHeight * 0.42).clamp(180.0, 320.0);

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                MinigameScoreBar(
                  scoreLabel: 'Cups: $_cupsStacked',
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
                              'Stack boba cups as high as you can!',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF5C4A42),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap Stack Cup to build your tower. '
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
                              scoreTitle: 'Cups stacked: $_cupsStacked',
                              onPlayAgain: _startGame,
                              onBackToMinigames: () => Navigator.of(context).pop(),
                              onBackToCafe: () => popBackToCafe(context),
                              playAgainKey: const Key('boba_stack_play_again'),
                            ),
                          ] else ...[
                            SizedBox(
                              height: stackHeight,
                              child: _StackArea(cupsStacked: _cupsStacked),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              key: const Key('boba_stack_cup'),
                              onPressed: _stackCup,
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Stack Cup'),
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

class _StackArea extends StatelessWidget {
  const _StackArea({required this.cupsStacked});

  final int cupsStacked;

  @override
  Widget build(BuildContext context) {
    final visibleCups = cupsStacked.clamp(0, 12);
    final hiddenCount = cupsStacked - visibleCups;

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
            padding: const EdgeInsets.all(12),
            child: Text(
              '🥛 Boba Stack!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5C4A42),
                  ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cupSize = (constraints.maxWidth * 0.22).clamp(44.0, 72.0);

                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      bottom: 8,
                      child: Container(
                        width: constraints.maxWidth * 0.55,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C4A42).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    for (var i = 0; i < visibleCups; i++)
                      Positioned(
                        bottom: 16 + i * (cupSize * 0.42),
                        child: _StackCup(
                          size: cupSize,
                          wobble: i >= 4 ? (i - 3) * 0.015 : 0,
                        ),
                      ),
                    if (cupsStacked == 0)
                      Positioned(
                        bottom: 40,
                        child: Text(
                          'Tap Stack Cup to begin!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF5C4A42).withValues(alpha: 0.55),
                              ),
                        ),
                      ),
                    if (hiddenCount > 0)
                      Positioned(
                        top: 8,
                        child: Text(
                          '+$hiddenCount more cups',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: const Color(0xFF5C4A42).withValues(alpha: 0.7),
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

class _StackCup extends StatelessWidget {
  const _StackCup({required this.size, required this.wobble});

  final double size;
  final double wobble;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: wobble,
      child: Container(
        width: size,
        height: size * 0.55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(
                const Color(0xFFE8A598),
                const Color(0xFFD4897A),
                wobble.clamp(0, 1),
              )!,
              const Color(0xFFD4897A),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text('🥤', style: TextStyle(fontSize: size * 0.32)),
      ),
    );
  }
}
