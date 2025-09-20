import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';
import 'package:flutter/foundation.dart';

// Mock Qwen AI Service - In a real app, you would integrate with the actual API
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

class AIService {
  // This is a mock implementation using minimax algorithm
  // In a real app, you would call the Qwen AI API here
  
  Future<List<int>?> getBestMove(Board board, String aiSymbol) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Use minimax algorithm to find best move
      final result = _minimax(board, aiSymbol, aiSymbol == 'X' ? 1 : -1, 0);
      
      if (result.move != null) {
        return result.move!;
      }
      
      // Fallback: get first available position
      final emptyPositions = board.getEmptyPositions();
      if (emptyPositions.isNotEmpty) {
        return emptyPositions[0];
      }
      
      return null;
    } catch (e) {
      debugPrint('Error in AI move: $e');
      rethrow;
    }
  }
  
  // Minimax algorithm implementation
  MinimaxResult _minimax(Board board, String aiSymbol, int player, int depth) {
    final opponent = player == 1 ? -1 : 1;
    final isMaximizing = player == 1;
    final currentSymbol = isMaximizing ? aiSymbol : (aiSymbol == 'X' ? 'O' : 'X');
    
    // Check terminal states
    final winner = board.getWinner();
    if (winner != null) {
      if (winner == aiSymbol) {
        return MinimaxResult(score: 10 - depth, move: null);
      } else {
        return MinimaxResult(score: depth - 10, move: null);
      }
    }
    
    if (board.isFull()) {
      return MinimaxResult(score: 0, move: null);
    }
    
    final emptyPositions = board.getEmptyPositions();
    
    if (isMaximizing) {
      int bestScore = -1000;
      List<int>? bestMove;
      
      for (final pos in emptyPositions) {
        final newBoard = Board.copy(board);
        newBoard.makeMove(pos[0], pos[1], currentSymbol);
        
        final result = _minimax(newBoard, aiSymbol, opponent, depth + 1);
        
        if (result.score > bestScore) {
          bestScore = result.score;
          bestMove = pos;
        }
      }
      
      return MinimaxResult(score: bestScore, move: bestMove);
    } else {
      int bestScore = 1000;
      List<int>? bestMove;
      
      for (final pos in emptyPositions) {
        final newBoard = Board.copy(board);
        newBoard.makeMove(pos[0], pos[1], currentSymbol);
        
        final result = _minimax(newBoard, aiSymbol, opponent, depth + 1);
        
        if (result.score < bestScore) {
          bestScore = result.score;
          bestMove = pos;
        }
      }
      
      return MinimaxResult(score: bestScore, move: bestMove);
    }
  }
}

class MinimaxResult {
  final int score;
  final List<int>? move;
  
  MinimaxResult({required this.score, this.move});
}