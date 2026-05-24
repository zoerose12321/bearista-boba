import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Loops cozy background music when the player opts in via [MusicToggleButton].
///
/// Background music is **off by default** so opening Bearista Boba does not
/// interrupt other apps' audio. Uses [musicAssetPath] only — never the coin
/// ding sound effect asset.
class MusicService extends ChangeNotifier {
  MusicService._() {
    _configurePlayer();
  }

  static final MusicService instance = MusicService._();

  /// Dedicated looping café track (not a short chime).
  static const musicAssetPath = 'music/cozy_boba_loop.mp3';

  /// Soft default volume so music stays in the background.
  static const musicVolume = 0.22;

  /// Mix with other apps instead of claiming exclusive audio focus when possible.
  static final AudioContext _mixingContext = AudioContext(
    android: AudioContextAndroid(
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
    iOS: AudioContextIOS(
      // Ambient does not interrupt other apps' audio on iOS.
      category: AVAudioSessionCategory.ambient,
    ),
  );

  final AudioPlayer _player = AudioPlayer();

  /// Player preference — false until the player turns music on.
  bool _enabled = false;
  bool _started = false;

  bool get isMusicEnabled => _enabled;

  Future<void> _configurePlayer() async {
    try {
      await _player.setAudioContext(_mixingContext);
      await _player.setPlayerMode(PlayerMode.mediaPlayer);
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(musicVolume);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('MusicService: player setup failed: $error');
      }
    }
  }

  /// Starts looping music after the player enables it. Safe to call multiple times.
  Future<void> startMusic() async {
    if (!_enabled) {
      return;
    }

    try {
      if (_started && _player.state == PlayerState.playing) {
        return;
      }

      await _player.setAudioContext(_mixingContext);
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

  /// Safe when music has never started — pauses the idle player.
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
