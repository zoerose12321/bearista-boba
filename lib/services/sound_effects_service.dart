import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays short game sound effects. Safe to call even if audio is unavailable.
class SoundEffectsService {
  SoundEffectsService._();

  static final SoundEffectsService instance = SoundEffectsService._();

  static const _coinSoundAsset = 'sounds/coin_ding.mp3';
  static const _coinVolume = 0.4;

  final AudioPlayer _player = AudioPlayer();

  /// Plays the coin reward ding after a correct order.
  Future<void> playCoinDing() async {
    try {
      await _player.stop();
      await _player.setVolume(_coinVolume);
      await _player.play(AssetSource(_coinSoundAsset));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('SoundEffectsService: coin ding failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }
}
