/// Pong Game Implementation
library;

/// Ball direction
class BallDirection {
  double dx;
  double dy;
  
  BallDirection(this.dx, this.dy);
}

/// Paddle
class Paddle {
  int x;
  int y;
  final int width;
  final int height;
  
  Paddle({
    required this.x,
    required this.y,
    this.width = 10,
    this.height = 60,
  });
}

/// Pong Game
class PongGame {
  final int width;
  final int height;
  
  Paddle leftPaddle;
  Paddle rightPaddle;
  
  int ballX;
  int ballY;
  BallDirection ballDir;
  
  int leftScore = 0;
  int rightScore = 0;
  
  bool isGameOver = false;
  int ballSpeed = 3;
  
  PongGame({
    this.width = 40,
    this.height = 20,
  }) : leftPaddle = Paddle(x: 2, y: height ~/ 2 - 30),
       rightPaddle = Paddle(x: width - 12, y: height ~/ 2 - 30),
       ballX = width ~/ 2,
       ballY = height ~/ 2,
       ballDir = BallDirection(1, 1) {
    _randomizeStartDirection();
  }
  
  void _randomizeStartDirection() {
    final random = DateTime.now().millisecondsSinceEpoch % 4;
    switch (random) {
      case 0:
        ballDir = BallDirection(1, 1);
        break;
      case 1:
        ballDir = BallDirection(1, -1);
        break;
      case 2:
        ballDir = BallDirection(-1, 1);
        break;
      case 3:
        ballDir = BallDirection(-1, -1);
        break;
    }
  }
  
  /// Move left paddle
  void moveLeftPaddle(int delta) {
    leftPaddle.y = (leftPaddle.y + delta).clamp(0, height - leftPaddle.height);
  }
  
  /// Move right paddle (AI or player)
  void moveRightPaddle(int delta) {
    rightPaddle.y = (rightPaddle.y + delta).clamp(0, height - rightPaddle.height);
  }
  
  /// Update game state
  bool update() {
    if (isGameOver) return false;
    
    // Move ball
    ballX += (ballDir.dx * ballSpeed).round();
    ballY += (ballDir.dy * ballSpeed).round();
    
    // Wall collision (top/bottom)
    if (ballY <= 0 || ballY >= height - 1) {
      ballDir.dy *= -1;
    }
    
    // Paddle collision
    // Left paddle
    if (ballX == leftPaddle.x + leftPaddle.width &&
        ballY >= leftPaddle.y &&
        ballY <= leftPaddle.y + leftPaddle.height) {
      ballDir.dx *= -1;
      ballDir.dy += (ballY - (leftPaddle.y + leftPaddle.height ~/ 2)) * 0.1;
      ballDir.dy = ballDir.dy.clamp(-2, 2);
    }
    
    // Right paddle
    if (ballX == rightPaddle.x - 1 &&
        ballY >= rightPaddle.y &&
        ballY <= rightPaddle.y + rightPaddle.height) {
      ballDir.dx *= -1;
      ballDir.dy += (ballY - (rightPaddle.y + rightPaddle.height ~/ 2)) * 0.1;
      ballDir.dy = ballDir.dy.clamp(-2, 2);
    }
    
    // Left wall - Right scores
    if (ballX < 0) {
      rightScore++;
      _resetBall();
    }
    
    // Right wall - Left scores
    if (ballX >= width) {
      leftScore++;
      _resetBall();
    }
    
    // Check game over (first to 10)
    if (leftScore >= 10 || rightScore >= 10) {
      isGameOver = true;
    }
    
    return true;
  }
  
  void _resetBall() {
    ballX = width ~/ 2;
    ballY = height ~/ 2;
    _randomizeStartDirection();
  }
  
  /// Simple AI for right paddle
  void aiMove() {
    final center = rightPaddle.y + rightPaddle.height ~/ 2;
    if (ballY < center - 5) {
      moveRightPaddle(-2);
    } else if (ballY > center + 5) {
      moveRightPaddle(2);
    }
  }
  
  /// Get game state for display
  Map<String, dynamic> getState() {
    return {
      'leftPaddle': {'x': leftPaddle.x, 'y': leftPaddle.y, 'height': leftPaddle.height},
      'rightPaddle': {'x': rightPaddle.x, 'y': rightPaddle.y, 'height': rightPaddle.height},
      'ball': {'x': ballX, 'y': ballY},
      'leftScore': leftScore,
      'rightScore': rightScore,
      'isGameOver': isGameOver,
      'winner': leftScore >= 10 ? 'Left' : (rightScore >= 10 ? 'Right' : null),
    };
  }
  
  /// Reset game
  void reset() {
    leftScore = 0;
    rightScore = 0;
    isGameOver = false;
    leftPaddle.y = height ~/ 2 - 30;
    rightPaddle.y = height ~/ 2 - 30;
    _resetBall();
  }
}

// Demo
void main() {
  final game = PongGame();
  
  print("Pong Game Demo");
  print("First to 10 wins!");
  
  // Simulate some updates
  game.update();
  
  print("Left: ${game.leftScore}, Right: ${game.rightScore}");
}