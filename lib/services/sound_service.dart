import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart'; // ✅ Added for debugPrint

// ✅ FIXED: Use relative import instead of package
import '../providers/settings_provider.dart';

final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService(ref);
});

class SoundService {
  final Ref _ref;
  final AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();

  SoundService(this._ref);

  Future<void> playMoveSound() async {
    final settingsState = _ref.read(settingsProvider);
    if (settingsState.soundEnabled) {
      try {
        await _audioPlayer.open(
          Audio("assets/sounds/move.mp3"),
          autoStart: true,
          volume: 0.3,
        );
      } catch (e) {
        // ✅ FIXED: print → debugPrint
        debugPrint('Error playing move sound: $e');
      }
    }
  }

  Future<void> playWinSound() async {
    final settingsState = _ref.read(settingsProvider);
    if (settingsState.soundEnabled) {
      try {
        await _audioPlayer.open(
          Audio("assets/sounds/win.mp3"),
          autoStart: true,
          volume: 0.5,
        );
      } catch (e) {
        // ✅ FIXED: print → debugPrint
        debugPrint('Error playing win sound: $e');
      }
    }
  }

  Future<void> playDrawSound() async {
    final settingsState = _ref.read(settingsProvider);
    if (settingsState.soundEnabled) {
      try {
        await _audioPlayer.open(
          Audio("assets/sounds/draw.mp3"),
          autoStart: true,
          volume: 0.4,
        );
      } catch (e) {
        // ✅ FIXED: print → debugPrint
        debugPrint('Error playing draw sound: $e');
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}