import 'dart:math';

/// Built-in game implementations
/// 6 games: Connect 4, Tic Tac Toe, Memory, Snake, Pong, Wordle

// ============== CONNECT 4 ==============

class Connect4Game {
  static const int rows = 6;
  static const int cols = 7;
  static const int player1 = 1;
  static const int player2 = 2;

  List<List<int>> board = List.generate(rows, (_) => List.filled(cols, 0));
  int currentPlayer = player1;
  int? winner;
  bool isDraw = false;

  /// Make a move in column
  bool makeMove(int col) {
    if (col < 0 || col >= cols || winner != null || isDraw) return false;

    // Find first empty row from bottom
    for (int row = rows - 1; row >= 0; row--) {
      if (board[row][col] == 0) {
        board[row][col] = currentPlayer;
        
        if (_checkWin(row, col)) {
          winner = currentPlayer;
        } else if (_isBoardFull()) {
          isDraw = true;
        } else {
          currentPlayer = currentPlayer == player1 ? player2 : player1;
        }
        return true;
      }
    }
    return false;
  }

  bool _checkWin(int row, int col) {
    return _checkDirection(row, col, 1, 0) || // Horizontal
           _checkDirection(row, col, 0, 1) || // Vertical
           _checkDirection(row, col, 1, 1) || // Diagonal \
           _checkDirection(row, col, 1, -1);   // Diagonal /
  }

  bool _checkDirection(int row, int col, int dRow, int dCol) {
    int count = 1;
    
    // Forward direction
    int r = row + dRow, c = col + dCol;
    while (r >= 0 && r < rows && c >= 0 && c < cols && board[r][c] == currentPlayer) {
      count++;
      r += dRow;
      c += dCol;
    }
    
    // Backward direction
    r = row - dRow;
    c = col - dCol;
    while (r >= 0 && r < rows && c >= 0 && c < cols && board[r][c] == currentPlayer) {
      count++;
      r -= dRow;
      c -= dCol;
    }
    
    return count >= 4;
  }

  bool _isBoardFull() {
    return board.every((row) => row.every((cell) => cell != 0));
  }

  void reset() {
    board = List.generate(rows, (_) => List.filled(cols, 0));
    currentPlayer = player1;
    winner = null;
    isDraw = false;
  }
}

// ============== TIC TAC TOE ==============

class TicTacToeGame {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String? winner;
  bool isDraw = false;

  static const List<List<int>> winPatterns = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
    [0, 4, 8], [2, 4, 6],             // Diagonals
  ];

  /// Make move at position
  bool makeMove(int pos) {
    if (pos < 0 || pos >= 9 || board[pos].isNotEmpty || winner != null || isDraw) {
      return false;
    }

    board[pos] = currentPlayer;

    if (_checkWin()) {
      winner = currentPlayer;
    } else if (!board.contains('')) {
      isDraw = true;
    } else {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    }
    return true;
  }

  bool _checkWin() {
    for (final pattern in winPatterns) {
      final a = board[pattern[0]];
      final b = board[pattern[1]];
      final c = board[pattern[2]];
      if (a.isNotEmpty && a == b && b == c) return true;
    }
    return false;
  }

  void reset() {
    board = List.filled(9, '');
    currentPlayer = 'X';
    winner = null;
    isDraw = false;
  }
}

// ============== MEMORY ==============

class MemoryGame {
  final int gridSize;
  List<int> cards = [];
  List<bool> revealed = [];
  int? firstCard;
  int moves = 0;
  int matches = 0;
  bool isComplete = false;

  MemoryGame({this.gridSize = 4}) {
    reset();
  }

  void reset() {
    // Create pairs of numbers
    final pairCount = (gridSize * gridSize) ~/ 2;
    cards = List.generate(pairCount, (i) => i + 1) * 2;
    cards.shuffle(Random());
    revealed = List.filled(cards.length, false);
    firstCard = null;
    moves = 0;
    matches = 0;
    isComplete = false;
  }

  /// Flip card at index
  int? flipCard(int index) {
    if (index < 0 || index >= cards.length || revealed[index]) return null;

    revealed[index] = true;

    if (firstCard == null) {
      firstCard = index;
      return null;
    }

    moves++;

    if (cards[index] == cards[firstCard!]) {
      // Match found
      matches++;
      firstCard = null;
      if (matches == cards.length ~/ 2) {
        isComplete = true;
      }
      return cards[index];
    } else {
      // No match - will need to hide both
      final first = firstCard;
      firstCard = null;
      return -cards[first!]; // Return negative to indicate mismatch
    }
  }

  /// Get unmatched card to hide
  int? getHiddenCard() => firstCard;
}

// ============== SNAKE ==============

class SnakeGame {
  static const int width = 20;
  static const int height = 15;

  List<List<int>> snake = [[5, 5], [5, 4], [5, 3]];
  List<int> food = [10, 7];
  String direction = 'right';
  String nextDirection = 'right';
  int score = 0;
  bool isGameOver = false;
  int speed = 150; // ms

  void reset() {
    snake = [[5, 5], [5, 4], [5, 3]];
    direction = 'right';
    nextDirection = 'right';
    score = 0;
    isGameOver = false;
    _spawnFood();
  }

  void _spawnFood() {
    final random = Random();
    bool valid = false;
    while (!valid) {
      food = [random.nextInt(width), random.nextInt(height)];
      valid = !snake.contains(food);
    }
  }

  void setDirection(String dir) {
    // Prevent 180 degree turns
    if (dir == 'up' && direction == 'down') return;
    if (dir == 'down' && direction == 'up') return;
    if (dir == 'left' && direction == 'right') return;
    if (dir == 'right' && direction == 'left') return;
    nextDirection = dir;
  }

  void update() {
    if (isGameOver) return;
    
    direction = nextDirection;
    final head = snake.first;
    List<int> newHead;

    switch (direction) {
      case 'up':
        newHead = [head[0], head[1] - 1];
        break;
      case 'down':
        newHead = [head[0], head[1] + 1];
        break;
      case 'left':
        newHead = [head[0] - 1, head[1]];
        break;
      case 'right':
        newHead = [head[0] + 1, head[1]];
        break;
      default:
        return;
    }

    // Check boundaries
    if (newHead[0] < 0 || newHead[0] >= width || 
        newHead[1] < 0 || newHead[1] >= height) {
      isGameOver = true;
      return;
    }

    // Check self-collision
    if (snake.contains(newHead)) {
      isGameOver = true;
      return;
    }

    snake.insert(0, newHead);

    // Check food
    if (newHead == food) {
      score += 10;
      _spawnFood();
      // Increase speed slightly
      if (speed > 50) speed -= 2;
    } else {
      snake.removeLast();
    }
  }
}

// ============== PONG ==============

class PongGame {
  static const int width = 30;
  static const int height = 15;

  int ballX = width ~/ 2;
  int ballY = height ~/ 2;
  int ballDX = 1;
  int ballDY = 1;
  int leftPaddleY = height ~/ 2;
  int rightPaddleY = height ~/ 2;
  int leftScore = 0;
  int rightScore = 0;
  bool isGameOver = false;
  int paddleSize = 3;

  void reset() {
    ballX = width ~/ 2;
    ballY = height ~/ 2;
    ballDX = 1;
    ballDY = 1;
    leftPaddleY = height ~/ 2;
    rightPaddleY = height ~/ 2;
    leftScore = 0;
    rightScore = 0;
    isGameOver = false;
  }

  void moveLeftPaddle(String direction) {
    if (direction == 'up' && leftPaddleY > 0) {
      leftPaddleY--;
    } else if (direction == 'down' && leftPaddleY < height - paddleSize) {
      leftPaddleY++;
    }
  }

  void moveRightPaddle(String direction) {
    if (direction == 'up' && rightPaddleY > 0) {
      rightPaddleY--;
    } else if (direction == 'down' && rightPaddleY < height - paddleSize) {
      rightPaddleY++;
    }
  }

  void update() {
    if (isGameOver) return;

    ballX += ballDX;
    ballY += ballDY;

    // Top/bottom walls
    if (ballY <= 0 || ballY >= height - 1) {
      ballDY = -ballDY;
    }

    // Left paddle
    if (ballX == 1 && ballY >= leftPaddleY && ballY < leftPaddleY + paddleSize) {
      ballDX = -ballDX;
    }

    // Right paddle
    if (ballX == width - 2 && ballY >= rightPaddleY && ballY < rightPaddleY + paddleSize) {
      ballDX = -ballDX;
    }

    // Left wall - point for right
    if (ballX < 0) {
      rightScore++;
      _resetBall();
    }

    // Right wall - point for left
    if (ballX > width - 1) {
      leftScore++;
      _resetBall();
    }

    // Game over at 5 points
    if (leftScore >= 5 || rightScore >= 5) {
      isGameOver = true;
    }
  }

  void _resetBall() {
    ballX = width ~/ 2;
    ballY = height ~/ 2;
    ballDX = (ballDX > 0 ? 1 : -1);
    ballDY = 1;
  }
}

// ============== WORDLE ==============

class WordleGame {
  static const List<String> wordList = [
    'PLATFORM', 'DECENT', 'NETWORK', 'PINC', 'CRYPTO',
    'MESH', 'DECENT', 'WALLET', 'GAMING', 'BLOCKCHAIN',
    'DECENTR', 'PRIVACY', 'SECURE', 'DECODE', 'PEER',
  ];
  
  late String targetWord;
  List<String> guesses = [];
  int currentGuess = 0;
  static const int maxGuesses = 6;
  bool isGameOver = false;
  bool isWon = false;

  WordleGame() {
    reset();
  }

  void reset() {
    targetWord = wordList[Random().nextInt(wordList.length)];
    guesses = List.filled(maxGuesses, '');
    currentGuess = 0;
    isGameOver = false;
    isWon = false;
  }

  /// Submit a guess
  bool submitGuess(String guess) {
    if (isGameOver || guess.length != 5) return false;

    guesses[currentGuess] = guess.toUpperCase();

    if (guess.toUpperCase() == targetWord) {
      isWon = true;
      isGameOver = true;
    } else if (currentGuess >= maxGuesses - 1) {
      isGameOver = true;
    } else {
      currentGuess++;
    }
    return true;
  }

  /// Get letter status for display
  /// 0 = not in word, 1 = wrong position, 2 = correct position
  List<int> getLetterStatus(int guessIndex, int letterIndex) {
    if (guessIndex >= guesses.length) return List.filled(5, 0);
    
    final guess = guesses[guessIndex];
    if (guess.isEmpty) return List.filled(5, 0);
    
    final letter = guess[letterIndex];
    final target = targetWord[letterIndex];
    
    if (letter == target) return 2;
    if (targetWord.contains(letter)) return 1;
    return 0;
  }

  /// Get remaining available letters
  List<String> getAvailableLetters() {
    final available = <String>[];
    final used = <String, int>{};
    
    for (final guess in guesses) {
      for (final letter in guess.split('')) {
        used[letter] = (used[letter] ?? 0) + 1;
      }
    }
    
    for (final letter in targetWord.split('')) {
      final count = used[letter] ?? 0;
      final inWord = targetWord.split('').where((l) => l == letter).length;
      if (count < inWord) {
        available.add(letter);
      }
    }
    
    return available;
  }
}