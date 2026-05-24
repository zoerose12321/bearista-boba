import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays short one-shot sound effects. Uses a separate player from [MusicService].
///
/// Sound effects never start background music and use a transient/mixing-friendly
/// audio context so they stay polite to other apps.
class SoundEffectsService {
  SoundEffectsService._() {
    _configurePlayer();
  }

  static final SoundEffectsService instance = SoundEffectsService._();

  static const coinSoundAssetPath = 'sounds/coin_ding.mp3';
  static const coinVolume = 0.4;

  static final AudioContext _sfxContext = AudioContext(
    android: AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.ambient,
    ),
  );

  final AudioPlayer _player = AudioPlayer();

  Future<void> _configurePlayer() async {
    try {
      await _player.setAudioContext(_sfxContext);
      await _player.setPlayerMode(PlayerMode.lowLatency);
      await _player.setReleaseMode(ReleaseMode.stop);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('SoundEffectsService: player setup failed: $error');
      }
    }
  }

  /// Plays the coin reward ding after a correct order.
  Future<void> playCoinDing() async {
    try {
      await _player.stop();
      await _player.setVolume(coinVolume);
      await _player.play(AssetSource(coinSoundAssetPath));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('SoundEffectsService: coin ding failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }
}
