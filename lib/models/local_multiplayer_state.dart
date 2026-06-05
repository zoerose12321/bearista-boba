import 'package:flutter/material.dart';

/// Local couch-co-op multiplayer state for ShopWorldPage (v0.1.52+).
class LocalMultiplayerState {
  bool isMultiplayerActive = false;
  bool isFriendHelperActive = false;
  double friendNormX = 0.44;
  double friendNormY = 0.64;

  static const friendName = 'Friend Bear';
  static const friendFurColor = Color(0xFFB8D4A8);
  static const friendAccentColor = Color(0xFF7EB8D4);
  static const friendMuzzleColor = Color(0xFFF0FAF0);
  static const friendBadgeEmoji = 'P2';

  String get statusLabel {
    if (!isMultiplayerActive) {
      return 'Solo Café';
    }
    if (isFriendHelperActive) {
      return 'Friend Helper Joined';
    }
    return 'Local Multiplayer Active';
  }

  void startLocalCafe() {
    isMultiplayerActive = true;
  }

  void addFriendHelper({
    required double playerNormX,
    required double playerNormY,
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
  }) {
    isMultiplayerActive = true;
    isFriendHelperActive = true;
    friendNormX = (playerNormX + 0.08).clamp(minX, maxX);
    friendNormY = (playerNormY + 0.05).clamp(minY, maxY);
  }

  void endMultiplayer() {
    isMultiplayerActive = false;
    isFriendHelperActive = false;
  }
}
