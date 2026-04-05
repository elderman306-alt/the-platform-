/// Snake Game Implementation
library;

/// Direction enum
enum Direction {
  up,
  down,
  left,
  right,
}

/// Snake segment
class SnakeSegment {
  final int x;
  final int y;
  
  SnakeSegment(this.x, this.y);
}

/// Snake Game
class SnakeGame {
  final int width;
  final int height;
  
  List<SnakeSegment> snake = [];
  Direction direction = Direction.right;
  Direction? nextDirection;
  
  int foodX = 0;
  int foodY = 0;
  
  int score = 0;
  bool isGameOver = false;
  int speed = 200; // ms per move
  
  SnakeGame({this.width = 20, this.height = 20}) {
    _initGame();
  }
  
  void _initGame() {
    // Start in middle
    snake = [
      SnakeSegment(width ~/ 2, height ~/ 2),
      SnakeSegment(width ~/ 2 - 1, height ~/ 2),
      SnakeSegment(width ~/ 2 - 2, height ~/ 2),
    ];
    direction = Direction.right;
    nextDirection = null;
    score = 0;
    isGameOver = false;
    _spawnFood();
  }
  
  void _spawnFood() {
    // Random position not on snake
    bool valid = false;
    while (!valid) {
      foodX = DateTime.now().millisecondsSinceEpoch % width;
      foodY = (DateTime.now().millisecondsSinceEpoch ~/ width) % height;
      
      valid = !snake.any((s) => s.x == foodX && s.y == foodY);
    }
  }
  
  /// Change direction
  void setDirection(Direction newDirection) {
    // Prevent 180 degree turns
    if (direction == Direction.up && newDirection == Direction.down) return;
    if (direction == Direction.down && newDirection == Direction.up) return;
    if (direction == Direction.left && newDirection == Direction.right) return;
    if (direction == Direction.right && newDirection == Direction.left) return;
    
    nextDirection = newDirection;
  }
  
  /// Update game state
  bool update() {
    if (isGameOver) return false;
    
    // Apply next direction
    if (nextDirection != null) {
      direction = nextDirection!;
      nextDirection = null;
    }
    
    // Calculate new head position
    int newX = snake.first.x;
    int newY = snake.first.y;
    
    switch (direction) {
      case Direction.up:
        newY--;
        break;
      case Direction.down:
        newY++;
        break;
      case Direction.left:
        newX--;
        break;
      case Direction.right:
        newX++;
        break;
    }
    
    // Check wall collision
    if (newX < 0 || newX >= width || newY < 0 || newY >= height) {
      isGameOver = true;
      return false;
    }
    
    // Check self collision
    if (snake.any((s) => s.x == newX && s.y == newY)) {
      isGameOver = true;
      return false;
    }
    
    // Add new head
    snake.insert(0, SnakeSegment(newX, newY));
    
    // Check food collision
    if (newX == foodX && newY == foodY) {
      score += 10;
      _spawnFood();
      // Don't remove tail - snake grows
    } else {
      // Remove tail
      snake.removeLast();
    }
    
    return true;
  }
  
  /// Get game state for display
  Map<String, dynamic> getState() {
    return {
      'snake': snake.map((s) => {'x': s.x, 'y': s.y}).toList(),
      'food': {'x': foodX, 'y': foodY},
      'direction': direction.name,
      'score': score,
      'isGameOver': isGameOver,
      'width': width,
      'height': height,
    };
  }
  
  /// Reset game
  void reset() {
    _initGame();
  }
}

// Demo
void main() {
  final game = SnakeGame();
  
  print("Snake Game Demo");
  print("Use setDirection() to control");
  
  // Simulate some moves
  game.setDirection(Direction.up);
  game.update();
  
  print("Score: ${game.score}");
  print("Game over: ${game.isGameOver}");
}