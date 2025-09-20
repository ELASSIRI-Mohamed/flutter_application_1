import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final bool soundEnabled;
  
  SettingsState({required this.soundEnabled});
  
  SettingsState copyWith({
    bool? soundEnabled,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState(soundEnabled: true)) {
    _loadSettingsFromPrefs();
  }
  
  Future<void> _loadSettingsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final soundEnabled = prefs.getBool('sound_enabled') ?? true;
    state = state.copyWith(soundEnabled: soundEnabled);
  }
  
  Future<void> toggleSound() async {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', state.soundEnabled);
  }
  
  Future<void> resetScores() async {
    // This will be handled by gameProvider
  }
}