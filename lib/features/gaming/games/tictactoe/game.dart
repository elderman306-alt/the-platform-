/// Tic Tac Toe Game Implementation
library;

/// Tic Tac Toe board
class TicTacToeBoard {
  static const int size = 3;
  
  final List<List<String>> board; // 'X', 'O', or ''
  
  TicTacToeBoard() : board = List.generate(
    size, 
    (_) => List.filled(size, '')
  );
  
  /// Make a move
  bool makeMove(int row, int col, String player) {
    if (board[row][col] != '') return false;
    board[row][col] = player;
    return true;
  }
  
  /// Check for win
  bool checkWin(String player) {
    // Check rows
    for (int row = 0; row < size; row++) {
      if (board[row][0] == player &&
          board[row][1] == player &&
          board[row][2] == player) {
        return true;
      }
    }
    
    // Check columns
    for (int col = 0; col < size; col++) {
      if (board[0][col] == player &&
          board[1][col] == player &&
          board[2][col] == player) {
        return true;
      }
    }
    
    // Check diagonals
    if (board[0][0] == player &&
        board[1][1] == player &&
        board[2][2] == player) {
      return true;
    }
    
    if (board[0][2] == player &&
        board[1][1] == player &&
        board[2][0] == player) {
      return true;
    }
    
    return false;
  }
  
  /// Check if board is full
  bool isFull() {
    return board.every((row) => row.every((cell) => cell != ''));
  }
  
  /// Reset board
  void reset() {
    for (var row in board) {
      for (int i = 0; i < row.length; i++) {
        row[i] = '';
      }
    }
  }
}

/// Tic Tac Toe Game
class TicTacToeGame {
  final TicTacToeBoard board = TicTacToeBoard();
  String currentPlayer = 'X'; // X starts
  String? winner;
  bool isGameOver = false;
  int moveCount = 0;
  
  /// Make a move
  bool makeMove(int row, int col) {
    if (isGameOver) return false;
    
    final success = board.makeMove(row, col, currentPlayer);
    if (!success) return false;
    
    moveCount++;
    
    // Check for win
    if (board.checkWin(currentPlayer)) {
      winner = currentPlayer;
      isGameOver = true;
    }
    // Check for draw
    else if (board.isFull()) {
      winner = null; // Draw
      isGameOver = true;
    }
    // Switch player
    else {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    }
    
    return true;
  }
  
  /// Get available moves
  List<List<int>> getAvailableMoves() {
    final moves = <List<int>>[];
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board.board[row][col] == '') {
          moves.add([row, col]);
        }
      }
    }
    return moves;
  }
  
  /// Get game state for display
  Map<String, dynamic> getState() {
    return {
      'board': board.board,
      'currentPlayer': currentPlayer,
      'winner': winner,
      'isGameOver': isGameOver,
      'moveCount': moveCount,
    };
  }
  
  /// Reset game
  void reset() {
    board.reset();
    currentPlayer = 'X';
    winner = null;
    isGameOver = false;
    moveCount = 0;
  }
}

// Demo
void main() {
  final game = TicTacToeGame();
  
  print("Tic Tac Toe Demo");
  print("Player X vs Player O");
  
  // X plays center
  game.makeMove(1, 1);
  print("X plays center");
  
  // O plays corner
  game.makeMove(0, 0);
  print("O plays corner");
  
  // X wins
  game.makeMove(0, 1);
  game.makeMove(2, 2);
  game.makeMove(0, 2);
  
  print("Winner: ${game.winner}");
  print("Game over: ${game.isGameOver}");
}