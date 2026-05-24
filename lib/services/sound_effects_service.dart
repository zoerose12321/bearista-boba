import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays short game sound effects. Safe to call even if audio is unavailable.
class SoundEffectsService {
  SoundEffectsService._();

  static final SoundEffectsService instance = SoundEffectsService._();

  static const _coinSoundAsset = 'sounds/coin_chaching.mp3';
  static const _coinVolume = 0.45;

  final AudioPlayer _player = AudioPlayer();

  /// Plays the coin reward cha-ching after a correct order.
  Future<void> playCoinChaching() async {
    try {
      await _player.stop();
      await _player.setVolume(_coinVolume);
      await _player.play(AssetSource(_coinSoundAsset));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('SoundEffectsService: coin sound failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }
}
