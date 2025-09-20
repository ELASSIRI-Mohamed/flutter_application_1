import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Relative imports — ✅ FIXED
import '../widgets/animated_x_o.dart';
import '../widgets/confetti_widget.dart';
import '../providers/game_provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String gameMode;

  const GameScreen({
    Key? key,
    required this.gameMode,
  }) : super(key: key);

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _turnIndicatorController;
  late Animation<double> _turnIndicatorOpacity;

  @override
  void initState() {
    super.initState();
    _turnIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _turnIndicatorOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _turnIndicatorController, curve: Curves.easeInOut),
    );

    _turnIndicatorController.forward();
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameMode != widget.gameMode) {
      ref.read(gameProvider.notifier).initializeGame(widget.gameMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    
    // Check if game just ended to show confetti
    bool showConfetti = state.winner != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.gameMode == 'ai' ? 'vs AI' : 'vs Friend',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showResetConfirmation(context),
          ),
        ],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
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
                children: [
                  // Current Turn Indicator
                  _buildTurnIndicator(state),
                  const SizedBox(height: 30),
                  
                  // Game Board
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boardSize = constraints.maxWidth;
                        return AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  // ✅ FIXED: withOpacity → withAlpha
                                  color: Theme.of(context).shadowColor.withAlpha((255 * 0.1).round()),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: _buildGameBoard(state, boardSize),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Action Button (if game over)
                  if (!state.isGameActive)
                    _buildActionButton(notifier),
                ],
              ),
            ),
          ),
          
          // Confetti overlay
          Positioned.fill(
            child: GameConfettiWidget( // ✅ Use the renamed widget
              isVisible: showConfetti,
              onFinished: () {
                if (!mounted) return;
                _showResultDialog(context, state.winner);
              },
            ),
          ),
          
          // AI Thinking indicator
          if (state.isAIThinking)
            _buildAIThinkingOverlay(),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator(GameState state) {
    return AnimatedBuilder(
      animation: _turnIndicatorController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _turnIndicatorOpacity,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // ✅ FIXED: withOpacity → withAlpha
                  color: Theme.of(context).shadowColor.withAlpha((255 * 0.1).round()),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.currentPlayer.symbol == 'X'
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  state.isGameActive
                      ? '${state.currentPlayer.name}\'s Turn'
                      : 'Game Over',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameBoard(GameState state, double boardSize) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final row = index ~/ 3;
        final col = index % 3;
        final symbol = state.board.cells[row][col];
        final isWinningCell = state.winningLine != null &&
            state.winningLine!.any((pos) => pos[0] == row && pos[1] == col);
        
        return AnimatedXO(
          symbol: symbol,
          isActive: state.isGameActive && symbol == null,
          onTap: () => _onCellTapped(row, col, state),
          isWinningCell: isWinningCell,
        );
      },
    );
  }

  void _onCellTapped(int row, int col, GameState state) {
    if (state.isGameActive && !state.isAIThinking) {
      ref.read(gameProvider.notifier).makeMove(row, col);
    }
  }

  Widget _buildActionButton(GameNotifier notifier) {
    return ElevatedButton(
      onPressed: () => _showPlayAgainConfirmation(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Text(
        'Play Again',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAIThinkingOverlay() {
    return Container(
      // ✅ FIXED: withOpacity → withAlpha
      color: Colors.black.withAlpha((255 * 0.3).round()),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'AI is thinking...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 void _showResultDialog(BuildContext context, String? winner) {
  Future.delayed(const Duration(milliseconds: 500), () {
    if (!mounted) return; // ✅ Guard against dead context
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String title;
        String message;
        Color color;
        
        if (winner == null) {
          title = 'It\'s a Draw!';
          message = 'No winner this time. Try again!';
          color = Theme.of(context).colorScheme.secondary;
        } else {
          title = 'Winner: $winner';
          message = winner == 'X' 
              ? 'Player X wins!' 
              : widget.gameMode == 'ai' ? 'AI wins!' : 'Player O wins!';
          color = winner == 'X' 
              ? Theme.of(context).colorScheme.error 
              : Theme.of(context).colorScheme.primary;
        }
        
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (winner != null)
                Container(
                  height: 4,
                  width: 100,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/home');
              },
              child: const Text('Back to Home'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showPlayAgainConfirmation(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: const Text('Play Again'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  });
}
  void _showPlayAgainConfirmation(BuildContext context) {
    ref.read(gameProvider.notifier).resetGame();
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Game'),
          content: const Text('Are you sure you want to start a new game? Current progress will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(gameProvider.notifier).resetGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _turnIndicatorController.dispose();
    super.dispose();
  }
}