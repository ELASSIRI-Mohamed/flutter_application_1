class Board {
  final List<List<String?>> cells;
  
  Board() : cells = List.generate(3, (_) => List.filled(3, null));
  
  // Create a copy of the board
  Board.copy(Board other) : cells = List.generate(3, (i) => List.from(other.cells[i]));
  
  // Check if position is empty
  bool isEmpty(int row, int col) {
    return cells[row][col] == null;
  }
  
  // Make a move
  void makeMove(int row, int col, String player) {
    if (isEmpty(row, col)) {
      cells[row][col] = player;
    }
  }
  
  // Get winner or null if no winner
  String? getWinner() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (cells[i][0] != null && 
          cells[i][0] == cells[i][1] && 
          cells[i][1] == cells[i][2]) {
        return cells[i][0];
      }
    }
    
    // Check columns
    for (int i = 0; i < 3; i++) {
      if (cells[0][i] != null && 
          cells[0][i] == cells[1][i] && 
          cells[1][i] == cells[2][i]) {
        return cells[0][i];
      }
    }
    
    // Check diagonals
    if (cells[0][0] != null && 
        cells[0][0] == cells[1][1] && 
        cells[1][1] == cells[2][2]) {
      return cells[0][0];
    }
    
    if (cells[0][2] != null && 
        cells[0][2] == cells[1][1] && 
        cells[1][1] == cells[2][0]) {
      return cells[0][2];
    }
    
    return null;
  }
  
  // Check if board is full
  bool isFull() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (cells[i][j] == null) {
          return false;
        }
      }
    }
    return true;
  }
  
  // Get empty positions
  List<List<int>> getEmptyPositions() {
    List<List<int>> positions = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (cells[i][j] == null) {
          positions.add([i, j]);
        }
      }
    }
    return positions;
  }
  
  // Check if game is over
  bool isGameOver() {
    return getWinner() != null || isFull();
  }
  
  // Get winning line if any
  List<List<int>>? getWinningLine() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (cells[i][0] != null && 
          cells[i][0] == cells[i][1] && 
          cells[i][1] == cells[i][2]) {
        return [[i, 0], [i, 1], [i, 2]];
      }
    }
    
    // Check columns
    for (int i = 0; i < 3; i++) {
      if (cells[0][i] != null && 
          cells[0][i] == cells[1][i] && 
          cells[1][i] == cells[2][i]) {
        return [[0, i], [1, i], [2, i]];
      }
    }
    
    // Check diagonals
    if (cells[0][0] != null && 
        cells[0][0] == cells[1][1] && 
        cells[1][1] == cells[2][2]) {
      return [[0, 0], [1, 1], [2, 2]];
    }
    
    if (cells[0][2] != null && 
        cells[0][2] == cells[1][1] && 
        cells[1][1] == cells[2][0]) {
      return [[0, 2], [1, 1], [2, 0]];
    }
    
    return null;
  }
}