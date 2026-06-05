import 'package:flutter/material.dart';

import '../models/player_character.dart';
import '../models/shop_game_state.dart';
import '../widgets/multiplayer_panel.dart';

class MultiplayerPage extends StatelessWidget {
  const MultiplayerPage({
    super.key,
    required this.player,
    required this.gameState,
  });

  final PlayerCharacter player;
  final ShopGameState gameState;

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
              player: player,
              gameState: gameState,
              onClose: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ),
    );
  }
}
