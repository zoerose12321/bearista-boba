import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/minigame_result.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../services/sound_effects_service.dart';
import '../widgets/minigame_common.dart';

enum _GamePhase { intro, playing, finished }

class TeaTimeDashGamePage extends StatefulWidget {
  const TeaTimeDashGamePage({
    super.key,
    required this.player,
    required this.gameState,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;

  /// Forces a recipe index in widget tests (0–2).
  static int? testSequenceIndex;

  @override
  State<TeaTimeDashGamePage> createState() => _TeaTimeDashGamePageState();
}

class _TeaTimeDashGamePageState extends State<TeaTimeDashGamePage> {
  static const _gameSeconds = 20;

  static const _allActions = [
    'Tea',
    'Milk',
    'Boba',
    'Ice',
    'Honey',
    'Shake',
    'Serve',
  ];

  static const _sequences = [
    ['Tea', 'Milk', 'Boba', 'Shake', 'Serve'],
    ['Tea', 'Ice', 'Boba', 'Shake', 'Serve'],
    ['Tea', 'Milk', 'Honey', 'Shake', 'Serve'],
  ];

  final Random _random = Random();

  _GamePhase _phase = _GamePhase.intro;
  int _drinksCompleted = 0;
  int _secondsLeft = _gameSeconds;
  bool _rewardClaimed = false;
  MinigameResult? _result;

  late List<String> _currentSequence;
  int _stepIndex = 0;
  String? _feedbackMessage;

  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _pickNewSequence() {
    final index = TeaTimeDashGamePage.testSequenceIndex ??
        _random.nextInt(_sequences.length);
    _currentSequence = List<String>.from(_sequences[index]);
    _stepIndex = 0;
  }

  void _startGame() {
    _countdownTimer?.cancel();

    setState(() {
      _phase = _GamePhase.playing;
      _drinksCompleted = 0;
      _secondsLeft = _gameSeconds;
      _rewardClaimed = false;
      _result = null;
      _feedbackMessage = null;
      _pickNewSequence();
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

  void _tapAction(String action) {
    if (_phase != _GamePhase.playing) {
      return;
    }

    final expected = _currentSequence[_stepIndex];
    if (action == expected) {
      setState(() {
        _feedbackMessage = null;
        _stepIndex++;
        if (_stepIndex >= _currentSequence.length) {
          _drinksCompleted++;
          _pickNewSequence();
        }
      });
      return;
    }

    setState(() {
      _feedbackMessage = 'Wrong step — follow the recipe!';
      if (_drinksCompleted > 0) {
        _drinksCompleted--;
      }
    });
  }

  void _finishGame() {
    _countdownTimer?.cancel();

    if (!_rewardClaimed) {
      final result = MinigameResult.fromTeaTimeDashScore(_drinksCompleted);
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
      title: 'Tea Time Dash',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            MinigameScoreBar(
              scoreLabel: 'Drinks: $_drinksCompleted',
              secondsLeft: _secondsLeft,
              coins: widget.gameState.coins,
              showTimer: _phase == _GamePhase.playing,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_phase == _GamePhase.intro) ...[
                          Text(
                            'Brew drinks in the right order!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF5C4A42),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap each prep step in order. '
                            'Earn 2 coins per completed drink (max ${MinigameResult.maxCoinReward}).',
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
                                MinigameResult.fromTeaTimeDashScore(_drinksCompleted),
                            scoreTitle: 'Drinks completed: $_drinksCompleted',
                            onPlayAgain: _startGame,
                            onBackToMinigames: () => Navigator.of(context).pop(),
                            onBackToCafe: () => popBackToCafe(context),
                            playAgainKey: const Key('tea_time_dash_play_again'),
                          ),
                        ] else ...[
                          _SequenceDisplay(
                            sequence: _currentSequence,
                            stepIndex: _stepIndex,
                          ),
                          if (_feedbackMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _feedbackMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: _allActions.map((action) {
                              return FilledButton.tonal(
                                key: Key('tea_dash_$action'),
                                onPressed: () => _tapAction(action),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(88, 44),
                                ),
                                child: Text(action),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SequenceDisplay extends StatelessWidget {
  const _SequenceDisplay({
    required this.sequence,
    required this.stepIndex,
  });

  final List<String> sequence;
  final int stepIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Text(
            '🍵 Current Recipe',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5C4A42),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < sequence.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: i < stepIndex
                        ? const Color(0xFFB8D4A8).withValues(alpha: 0.55)
                        : i == stepIndex
                            ? const Color(0xFFE8A598)
                            : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: i == stepIndex
                          ? const Color(0xFFD4897A)
                          : const Color(0xFFD4A574).withValues(alpha: 0.4),
                      width: i == stepIndex ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    '${i + 1}. ${sequence[i]}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight:
                          i == stepIndex ? FontWeight.bold : FontWeight.w500,
                      color: const Color(0xFF5C4A42),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
