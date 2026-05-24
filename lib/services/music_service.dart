import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Loops cozy background music across the main game screens.
///
/// Uses [musicAssetPath] only — never the coin ding sound effect asset.
class MusicService extends ChangeNotifier {
  MusicService._() {
    _configurePlayer();
  }

  static final MusicService instance = MusicService._();

  /// Dedicated looping café track (not a short chime).
  static const musicAssetPath = 'music/cozy_boba_loop.mp3';

  /// Soft default volume so music stays in the background.
  static const musicVolume = 0.22;

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;
  bool _started = false;

  bool get isMusicEnabled => _enabled;

  Future<void> _configurePlayer() async {
    try {
      await _player.setPlayerMode(PlayerMode.mediaPlayer);
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(musicVolume);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('MusicService: player setup failed: $error');
      }
    }
  }

  /// Starts looping music after a user gesture. Safe to call multiple times.
  Future<void> startMusic() async {
    if (!_enabled) {
      return;
    }

    try {
      if (_started && _player.state == PlayerState.playing) {
        return;
      }

      await _player.setVolume(musicVolume);
      await _player.setReleaseMode(ReleaseMode.loop);

      if (_started) {
        await _player.resume();
        return;
      }

      await _player.play(AssetSource(musicAssetPath));
      _started = true;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'MusicService: could not play $musicAssetPath — '
          'add a cozy loop at assets/$musicAssetPath',
        );
        debugPrint('$error');
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
