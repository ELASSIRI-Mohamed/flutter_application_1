import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';
import '../models/player.dart';
import '../services/ai_service.dart';
import '../services/sound_service.dart';
import 'package:flutter/foundation.dart'; 

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final soundService = ref.watch(soundServiceProvider);
  return GameNotifier(aiService: aiService, soundService: soundService);
});

class GameState {
  final Board board;
  final Player currentPlayer;
  final Player playerX;
  final Player playerO;
  final String gameMode;
  final bool isGameActive;
  final String? winner;
  final List<List<int>>? winningLine;
  final Map<String, int> scores;
  final bool isAIThinking;
  
  GameState({
    required this.board,
    required this.currentPlayer,
    required this.playerX,
    required this.playerO,
    required this.gameMode,
    required this.isGameActive,
    this.winner,
    this.winningLine,
    required this.scores,
    this.isAIThinking = false,
  });
  
  GameState copyWith({
    Board? board,
    Player? currentPlayer,
    Player? playerX,
    Player? playerO,
    String? gameMode,
    bool? isGameActive,
    String? winner,
    List<List<int>>? winningLine,
    Map<String, int>? scores,
    bool? isAIThinking,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      playerX: playerX ?? this.playerX,
      playerO: playerO ?? this.playerO,
      gameMode: gameMode ?? this.gameMode,
      isGameActive: isGameActive ?? this.isGameActive,
      winner: winner ?? this.winner,
      winningLine: winningLine ?? this.winningLine,
      scores: scores ?? this.scores,
      isAIThinking: isAIThinking ?? this.isAIThinking,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final AIService aiService;
  final SoundService soundService;
  
  GameNotifier({required this.aiService, required this.soundService}) : super(
    GameState(
      board: Board(),
      currentPlayer: Player(symbol: 'X', type: PlayerType.human, name: 'Player X'),
      playerX: Player(symbol: 'X', type: PlayerType.human, name: 'Player X'),
      playerO: Player(symbol: 'O', type: PlayerType.human, name: 'Player O'),
      gameMode: 'friend',
      isGameActive: true,
      scores: {'X': 0, 'O': 0, 'draws': 0},
    )
  );
  
  void initializeGame(String gameMode) {
    Player playerO;
    
    if (gameMode == 'ai') {
      playerO = Player(symbol: 'O', type: PlayerType.ai, name: 'AI');
    } else {
      playerO = Player(symbol: 'O', type: PlayerType.human, name: 'Player O');
    }
    
    state = state.copyWith(
      board: Board(),
      currentPlayer: Player(symbol: 'X', type: PlayerType.human, name: 'Player X'),
      playerX: Player(symbol: 'X', type: PlayerType.human, name: 'Player X'),
      playerO: playerO,
      gameMode: gameMode,
      isGameActive: true,
      winner: null,
      winningLine: null,
      isAIThinking: false,
    );
    
    // If AI plays first (when AI is X), make AI move
    if (gameMode == 'ai' && state.currentPlayer.type == PlayerType.ai) {
      makeAIMove();
    }
  }
  
  void makeMove(int row, int col) {
    // Don't allow moves if game is over or cell is not empty
    if (!state.isGameActive || !state.board.isEmpty(row, col)) {
      return;
    }
    
    // Don't allow human to move when AI is thinking
    if (state.isAIThinking) {
      return;
    }
    
    // Play move sound
    soundService.playMoveSound();
    
    // Create a new board with the move
    final newBoard = Board.copy(state.board);
    newBoard.makeMove(row, col, state.currentPlayer.symbol);
    
    // Check for winner
    final winner = newBoard.getWinner();
    final isFull = newBoard.isFull();
    final winningLine = newBoard.getWinningLine();
    
    // Update state
    state = state.copyWith(
      board: newBoard,
      winner: winner,
      winningLine: winningLine,
    );
    
    // Check if game is over
    if (winner != null) {
      // Game won
      state = state.copyWith(
        isGameActive: false,
      );
      
      // Update scores
      final updatedScores = Map<String, int>.from(state.scores);
      updatedScores[winner] = (updatedScores[winner] ?? 0) + 1;
      state = state.copyWith(scores: updatedScores);
      
      // Play win sound
      soundService.playWinSound();
      
      return;
    } else if (isFull) {
      // Game drawn
      state = state.copyWith(
        isGameActive: false,
      );
      
      // Update draw scores
      final updatedScores = Map<String, int>.from(state.scores);
      updatedScores['draws'] = (updatedScores['draws'] ?? 0) + 1;
      state = state.copyWith(scores: updatedScores);
      
      // Play draw sound
      soundService.playDrawSound();
      
      return;
    }
    
    // Switch to next player
    final nextPlayer = state.currentPlayer.symbol == 'X' ? state.playerO : state.playerX;
    state = state.copyWith(currentPlayer: nextPlayer);
    
    // If next player is AI, make AI move
    if (nextPlayer.type == PlayerType.ai) {
      makeAIMove();
    }
  }
  
  Future<void> makeAIMove() async {
    if (!state.isGameActive || state.currentPlayer.type != PlayerType.ai) {
      return;
    }
    
    // Set AI thinking state
    state = state.copyWith(isAIThinking: true);
    
    try {
      // Get AI move
      final move = await aiService.getBestMove(Board.copy(state.board), state.currentPlayer.symbol);
      
      // Small delay to make it feel more natural
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Make the move if valid
      if (move != null && move.length == 2) {
        final row = move[0];
        final col = move[1];
        
        if (row >= 0 && row < 3 && col >= 0 && col < 3 && state.board.isEmpty(row, col)) {
          makeMove(row, col);
        }
      }
    } catch (e) {
      debugPrint('Error in AI move: $e');
      // Fallback: make a random move
      final emptyPositions = state.board.getEmptyPositions();
      if (emptyPositions.isNotEmpty) {
        final randomMove = emptyPositions[0]; // In production, use proper random selection
        makeMove(randomMove[0], randomMove[1]);
      }
    } finally {
      // Reset AI thinking state
      state = state.copyWith(isAIThinking: false);
    }
  }
  
  void resetGame() {
    // Create new board
    final newBoard = Board();
    
    // Keep the same players and game mode
    state = state.copyWith(
      board: newBoard,
      currentPlayer: Player(symbol: 'X', type: PlayerType.human, name: 'Player X'),
      isGameActive: true,
      winner: null,
      winningLine: null,
      isAIThinking: false,
    );
    
    // If AI should play first, make AI move
    if (state.gameMode == 'ai' && state.currentPlayer.type == PlayerType.ai) {
      makeAIMove();
    }
  }
  
  void resetScores() {
    state = state.copyWith(
      scores: {'X': 0, 'O': 0, 'draws': 0},
    );
  }
}