import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// ✅ FIXED: Use relative imports
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/game_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ All providers now properly imported
    final themeNotifier = ref.watch(themeProvider.notifier);
    final settingsNotifier = ref.watch(settingsProvider.notifier);
    final settingsState = ref.watch(settingsProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // ✅ FIXED: withOpacity → withAlpha
              Theme.of(context).colorScheme.primary.withAlpha((255 * 0.05).round()),
              // ✅ FIXED: background → surface
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              
              // Theme Toggle
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    ref.watch(themeProvider) == ThemeMode.dark 
                        ? 'Dark theme enabled' 
                        : 'Light theme enabled',
                    style: TextStyle(
                      // ✅ FIXED: withOpacity → withAlpha
                      color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                    ),
                  ),
                  trailing: Switch(
                    value: ref.watch(themeProvider) == ThemeMode.dark,
                    onChanged: (value) async {
                      await themeNotifier.toggleTheme();
                    },
                    // ✅ FIXED: activeColor → activeThumbColor
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Sound Toggle
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    'Sound Effects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    settingsState.soundEnabled 
                        ? 'Sound effects enabled' 
                        : 'Sound effects disabled',
                    style: TextStyle(
                      // ✅ FIXED: withOpacity → withAlpha
                      color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                    ),
                  ),
                  trailing: Switch(
                    value: settingsState.soundEnabled,
                    onChanged: (value) async {
                      await settingsNotifier.toggleSound();
                    },
                    // ✅ FIXED: activeColor → activeThumbColor
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Reset Scores Button
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    'Reset Scores',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Reset all game scores to zero',
                    style: TextStyle(
                      // ✅ FIXED: withOpacity → withAlpha
                      color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                    ),
                  ),
                  trailing: const Icon(Icons.delete_outline),
                  onTap: () => _showResetScoresConfirmation(context, gameNotifier),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // App Info
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Divider(),
                      const SizedBox(height: 20),
                      Text(
                        'Tic Tac Toe v1.0.0',
                        style: TextStyle(
                          fontSize: 14,
                          // ✅ FIXED: withOpacity → withAlpha
                          color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                        ),
                      ),
                      Text(
                        'Made with Flutter',
                        style: TextStyle(
                          fontSize: 12,
                          // ✅ FIXED: withOpacity → withAlpha
                          color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetScoresConfirmation(BuildContext context, GameNotifier gameNotifier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Scores'),
          content: const Text('Are you sure you want to reset all scores to zero? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                gameNotifier.resetScores();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}