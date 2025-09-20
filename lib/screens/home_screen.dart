import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ✅ FIXED: Use relative import instead of package
import '../widgets/score_card.dart';
import '../providers/game_provider.dart'; // ✅ Added missing import

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<Offset> _titleSlideAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _titleController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scores = ref.watch(gameProvider).scores;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // ✅ FIXED: withOpacity → withAlpha
              Theme.of(context).colorScheme.primary.withAlpha((255 * 0.1).round()),
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
              // Animated Title
              SlideTransition(
                position: _titleSlideAnimation,
                child: Text(
                  'Tic Tac Toe',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              SlideTransition(
                position: _titleSlideAnimation,
                child: Text(
                  'Choose Your Game Mode',
                  style: TextStyle(
                    fontSize: 18,
                    // ✅ FIXED: onBackground → onSurface
                    color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              
              // Score Cards
              if (scores['X'] != 0 || scores['O'] != 0 || scores['draws'] != 0)
                Column(
                  children: [
                    Text(
                      'SCORES',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        // ✅ FIXED: onBackground → onSurface
                        color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ScoreCard(
                          title: 'Player X',
                          score: scores['X'] ?? 0,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        ScoreCard(
                          title: 'Draws',
                          score: scores['draws'] ?? 0,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        ScoreCard(
                          title: 'Player O',
                          score: scores['O'] ?? 0,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              
              // Game Mode Buttons
              _buildGameButton(
                context,
                icon: Icons.android,
                text: 'Play vs AI',
                onPressed: () => _startGame('ai'),
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              _buildGameButton(
                context,
                icon: Icons.people,
                text: 'Play vs Friend',
                onPressed: () => _startGame('friend'),
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              _buildGameButton(
                context,
                icon: Icons.settings,
                text: 'Settings',
                onPressed: () => context.go('/settings'),
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        // ✅ FIXED: withOpacity → withAlpha
        shadowColor: color.withAlpha((255 * 0.4).round()),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _startGame(String gameMode) {
    // Initialize game with selected mode
    ref.read(gameProvider.notifier).initializeGame(gameMode);
    // Navigate to game screen
    context.go('/game', extra: gameMode);
  }
}