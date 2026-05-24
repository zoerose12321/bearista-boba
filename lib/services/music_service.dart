import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Loops cozy background music across the main game screens.
class MusicService extends ChangeNotifier {
  MusicService._();

  static final MusicService instance = MusicService._();

  static const _musicAsset = 'music/cozy_boba_loop.mp3';
  static const musicVolume = 0.22;

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;
  bool _started = false;

  bool get isMusicEnabled => _enabled;

  /// Starts looping music after a user gesture. Safe to call multiple times.
  Future<void> startMusic() async {
    if (!_enabled) {
      return;
    }

    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(musicVolume);

      if (_started && _player.state == PlayerState.playing) {
        return;
      }

      if (_started) {
        await _player.resume();
        return;
      }

      await _player.play(AssetSource(_musicAsset));
      _started = true;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('MusicService: start failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> stopMusic() async {
    try {
      await _player.pause();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('MusicService: stop failed: $error');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> toggleMusic() async {
    _enabled = !_enabled;
    notifyListeners();

    if (_enabled) {
      await startMusic();
    } else {
      await stopMusic();
    }
  }
}
