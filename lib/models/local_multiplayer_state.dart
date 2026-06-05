import 'package:flutter/material.dart';

/// Local multiplayer and helper state for ShopWorldPage (v0.1.52+).
class LocalMultiplayerState {
  bool isLocalCafeActive = false;
  bool isHelperActive = false;
  double friendNormX = 0.44;
  double friendNormY = 0.64;

  static const helperName = 'Helper Bear';
  static const friendFurColor = Color(0xFFB8D4A8);
  static const friendAccentColor = Color(0xFF7EB8D4);
  static const friendMuzzleColor = Color(0xFFF0FAF0);
  static const helperBadgeEmoji = '✨';

  String get statusLabel {
    if (isHelperActive) {
      return 'Helper Bear Active';
    }
    if (isLocalCafeActive) {
      return 'Local Multiplayer Active';
    }
    return 'Solo Café';
  }

  void startLocalCafe() {
    isLocalCafeActive = true;
  }

  void endLocalCafe() {
    isLocalCafeActive = false;
  }

  void activateHelper({
    required double playerNormX,
    required double playerNormY,
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
  }) {
    isHelperActive = true;
    friendNormX = (playerNormX + 0.08).clamp(minX, maxX);
    friendNormY = (playerNormY + 0.05).clamp(minY, maxY);
  }

  void sendHelperHome() {
    isHelperActive = false;
  }
}
