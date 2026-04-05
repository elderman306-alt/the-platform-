/// Connect 4 Game Implementation
library;

/// Connect 4 board
class Connect4Board {
  static const int rows = 6;
  static const int columns = 7;
  
  final List<List<int>> board; // 0 = empty, 1 = player1, 2 = player2
  
  Connect4Board() : board = List.generate(
    rows, 
    (_) => List.filled(columns, 0)
  );
  
  /// Drop a piece in a column
  /// Returns the row where piece was placed, or -1 if column full
  int dropPiece(int column, int player) {
    for (int row = rows - 1; row >= 0; row--) {
      if (board[row][column] == 0) {
        board[row][column] = player;
        return row;
      }
    }
    return -1; // Column full
  }
  
  /// Check if a column has space
  bool canDropPiece(int column) {
    return board[0][column] == 0;
  }
  
  /// Check for winning condition
  bool checkWin(int player) {
    // Check horizontal
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col <= columns - 4; col++) {
        if (board[row][col] == player &&
            board[row][col + 1] == player &&
            board[row][col + 2] == player &&
            board[row][col + 3] == player) {
          return true;
        }
      }
    }
    
    // Check vertical
    for (int row = 0; row <= rows - 4; row++) {
      for (int col = 0; col < columns; col++) {
        if (board[row][col] == player &&
            board[row + 1][col] == player &&
            board[row + 2][col] == player &&
            board[row + 3][col] == player) {
          return true;
        }
      }
    }
    
    // Check diagonal (down-right)
    for (int row = 0; row <= rows - 4; row++) {
      for (int col = 0; col <= columns - 4; col++) {
        if (board[row][col] == player &&
            board[row + 1][col + 1] == player &&
            board[row + 2][col + 2] == player &&
            board[row + 3][col + 3] == player) {
          return true;
        }
      }
    }
    
    // Check diagonal (up-right)
    for (int row = 3; row < rows; row++) {
      for (int col = 0; col <= columns - 4; col++) {
        if (board[row][col] == player &&
            board[row - 1][col + 1] == player &&
            board[row - 2][col + 2] == player &&
            board[row - 3][col + 3] == player) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Check if board is full (draw)
  bool isFull() {
    return board.every((row) => row.every((cell) => cell != 0));
  }
  
  /// Reset board
  void reset() {
    for (var row in board) {
      for (int i = 0; i < row.length; i++) {
        row[i] = 0;
      }
    }
  }
}

/// Connect 4 Game
class Connect4Game {
  final Connect4Board board = Connect4Board();
  int currentPlayer = 1; // Player 1 starts
  String? winner;
  bool isGameOver = false;
  
  /// Make a move
  /// Returns true if move was successful
  bool makeMove(int column) {
    if (isGameOver) return false;
    if (!board.canDropPiece(column)) return false;
    
    final row = board.dropPiece(column, currentPlayer);
    if (row == -1) return false;
    
    // Check for win
    if (board.checkWin(currentPlayer)) {
      winner = "Player $currentPlayer";
      isGameOver = true;
    }
    // Check for draw
    else if (board.isFull()) {
      winner = null; // Draw
      isGameOver = true;
    }
    // Switch player
    else {
      currentPlayer = currentPlayer == 1 ? 2 : 1;
    }
    
    return true;
  }
  
  /// Get game state for display
  Map<String, dynamic> getState() {
    return {
      'board': board.board,
      'currentPlayer': currentPlayer,
      'winner': winner,
      'isGameOver': isGameOver,
    };
  }
  
  /// Reset game
  void reset() {
    board.reset();
    currentPlayer = 1;
    winner = null;
    isGameOver = false;
  }
}

// Demo
void main() {
  final game = Connect4Game();
  
  // Simulate a game
  print("Connect 4 Demo");
  print("Player 1 (X) vs Player 2 (O)");
  
  // Player 1 drops in column 3
  game.makeMove(3);
  print("P1 drops in col 3");
  
  // Player 2 drops in column 3
  game.makeMove(3);
  print("P2 drops in col 3");
  
  // Player 1 wins with horizontal
  game.makeMove(4);
  game.makeMove(4);
  game.makeMove(4);
  final winMove = game.makeMove(4);
  
  print("Player 1 wins: $winMove");
  print("Winner: ${game.winner}");
  print("Game over: ${game.isGameOver}");
}