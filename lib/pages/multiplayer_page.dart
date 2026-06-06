import 'package:flutter/material.dart';

import '../models/local_multiplayer_state.dart';
import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../widgets/multiplayer_panel.dart';

class MultiplayerPage extends StatefulWidget {
  const MultiplayerPage({
    super.key,
    required this.player,
    required this.gameState,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;

  @override
  State<MultiplayerPage> createState() => _MultiplayerPageState();
}

class _MultiplayerPageState extends State<MultiplayerPage> {
  final LocalMultiplayerState _multiplayerState = LocalMultiplayerState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplayer'),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: MultiplayerPanel(
              player: widget.player,
              gameState: widget.gameState,
              multiplayerState: _multiplayerState,
              onClose: () => Navigator.of(context).maybePop(),
              onPurchaseHelper: () => setState(() {
                if (_multiplayerState.canPurchaseHelperBear(
                  widget.gameState.coins,
                )) {
                  widget.gameState.coins -=
                      LocalMultiplayerState.helperBearUnlockCost;
                  _multiplayerState.isHelperBearUnlocked = true;
                }
              }),
              onActivateHelper: () => setState(() {
                if (!_multiplayerState.isHelperBearUnlocked) {
                  return;
                }
                _multiplayerState.activateHelper(
                  playerNormX: 0.36,
                  playerNormY: 0.68,
                  minX: 0.36,
                  maxX: 0.89,
                  minY: 0.09,
                  maxY: 0.84,
                );
              }),
              onSendHelperHome: () =>
                  setState(() => _multiplayerState.sendHelperHome()),
              onStartLocalCafe: () =>
                  setState(() => _multiplayerState.startLocalCafe()),
              onEndLocalCafe: () =>
                  setState(() => _multiplayerState.endLocalCafe()),
            ),
          ),
        ),
      ),
    );
  }
}
