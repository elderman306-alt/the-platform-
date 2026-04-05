/// Gaming UI Screens
library;

import 'package:flutter/material.dart';
import '../games/connect4/game.dart';
import '../games/tictactoe/game.dart';
import '../games/memory_match/game.dart';
import '../games/snake/game.dart';
import '../games/pong/game.dart';
import '../games/wordle/game.dart';

/// Main gaming hub screen
class GamingHubScreen extends StatelessWidget {
  const GamingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E14),
        title: const Text(
          '🎮 Gaming Hub',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF00D4AA),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard, color: Color(0xFF00D4AA)),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // League status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emoji_events, color: Color(0xFF00D4AA), size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your League Rank', style: TextStyle(color: Colors.grey)),
                        Text('#42', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00D4AA))),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Points', style: TextStyle(color: Colors.grey)),
                      Text('250', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Single Player', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildGameCard(context, 'Snake', '🐍', const SnakeGameScreen()),
                  _buildGameCard(context, 'Wordle', '📝', const WordleGameScreen()),
                  _buildGameCard(context, 'Memory', '🧠', const MemoryMatchGameScreen()),
                  _buildGameCard(context, 'Pong', '🏓', const PongGameScreen()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Multiplayer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildGameCard(context, 'Connect 4', '🔴', const Connect4GameScreen()),
                _buildGameCard(context, 'Tic Tac Toe', '❌', const TicTacToeGameScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, String emoji, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00D4AA).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

/// Connect 4 Game Screen
class Connect4GameScreen extends StatefulWidget {
  const Connect4GameScreen({super.key});

  @override
  State<Connect4GameScreen> createState() => _Connect4GameScreenState();
}

class _Connect4GameScreenState extends State<Connect4GameScreen> {
  final Connect4Game _game = Connect4Game();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E14),
        title: Text(
          _game.isGameOver ? 'Game Over - ${_game.winner ?? "Draw"}' : 'Connect 4 - Player ${_game.currentPlayer}',
          style: const TextStyle(color: Color(0xFF00D4AA)),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: _buildBoard())),
          if (_game.isGameOver)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
                onPressed: () => setState(() => _game.reset()),
                child: const Text('Play Again'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(Connect4Board.rows, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(Connect4Board.columns, (col) {
              final cell = _game.board.board[row][col];
              return GestureDetector(
                onTap: () => _handleTap(col),
                child: Container(
                  width: 40, height: 40, margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: cell == 0 ? const Color(0xFF2E2E2E) : (cell == 1 ? Colors.red : Colors.yellow),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  void _handleTap(int col) {
    if (_game.isGameOver) return;
    setState(() => _game.makeMove(col));
  }
}

/// Tic Tac Toe Screen
class TicTacToeGameScreen extends StatefulWidget {
  const TicTacToeGameScreen({super.key});

  @override
  State<TicTacToeGameScreen> createState() => _TicTacToeGameScreenState();
}

class _TicTacToeGameScreenState extends State<TicTacToeGameScreen> {
  final TicTacToeGame _game = TicTacToeGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E14),
        title: Text(
          _game.isGameOver ? 'Game Over - ${_game.winner ?? "Draw"}' : 'Tic Tac Toe - ${_game.currentPlayer}\'s Turn',
          style: const TextStyle(color: Color(0xFF00D4AA)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: List.generate(3, (row) {
                  return Row(
                    children: List.generate(3, (col) {
                      return GestureDetector(
                        onTap: () => _handleTap(row, col),
                        child: Container(
                          width: 80, height: 80,
                          decoration: const BoxDecoration(border: Border.all(color: Color(0xFF00D4AA))),
                          child: Center(
                            child: Text(
                              _game.board.board[row][col],
                              style: TextStyle(fontSize: 40, color: _game.board.board[row][col] == 'X' ? Colors.red : Colors.blue),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
            if (_game.isGameOver)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
                  onPressed: () => setState(() => _game.reset()),
                  child: const Text('Play Again'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleTap(int row, int col) {
    if (_game.isGameOver) return;
    setState(() => _game.makeMove(row, col));
  }
}

/// Memory Match Screen
class MemoryMatchGameScreen extends StatefulWidget {
  const MemoryMatchGameScreen({super.key});

  @override
  State<MemoryMatchGameScreen> createState() => _MemoryMatchGameScreenState();
}

class _MemoryMatchGameScreenState extends State<MemoryMatchGameScreen> {
  final MemoryMatchGame _game = MemoryMatchGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E14),
        title: Text('Memory Match - Moves: ${_game.moves}', style: const TextStyle(color: Color(0xFF00D4AA))),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF00D4AA)), onPressed: () => setState(() => _game.reset())),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: _game.cards.length,
        itemBuilder: (context, index) {
          final card = _game.cards[index];
          return GestureDetector(
            onTap: () => setState(() => _game.flipCard(index)),
            child: Container(
              decoration: BoxDecoration(
                color: card.state == CardState.hidden ? const Color(0xFF1E1E1E) : (card.state == CardState.matched ? const Color(0xFF00D4AA).withOpacity(0.3) : const Color(0xFF2E2E2E)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: card.state != CardState.hidden ? Text(card.symbol, style: const TextStyle(fontSize: 32)) : const Icon(Icons.question_mark, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Snake Game Screen
class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  final SnakeGame _game = SnakeGame();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _startGameLoop();
  }

  void _startGameLoop() {
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: _game.speed));
      if (mounted && _isPlaying && !_game.isGameOver) {
        setState(() => _game.update());
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(backgroundColor: const Color(0xFF0A0E14), title: Text('Snake - Score: ${_game.score}', style: const TextStyle(color: Color(0xFF00D4AA)))),
      body: Column(
        children: [
          Expanded(child: Center(child: Container(width: 300, height: 300, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF00D4AA))), child: CustomPaint(painter: SnakePainter(_game))))),
          if (!_isPlaying || _game.isGameOver)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
                onPressed: () { setState(() { _game.reset(); _isPlaying = true; _startGameLoop(); }); },
                child: Text(_game.isGameOver ? 'Play Again' : 'Start Game'),
              ),
            ),
          if (_isPlaying)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _buildDirectionButton('↑', Direction.up),
              ]),
            ),
          if (_isPlaying)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _buildDirectionButton('←', Direction.left),
                _buildDirectionButton('↓', Direction.down),
                _buildDirectionButton('→', Direction.right),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(String emoji, Direction dir) {
    return GestureDetector(
      onTap: () => _game.setDirection(dir),
      child: Container(width: 50, height: 50, margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24)))),
    );
  }
}

class SnakePainter extends CustomPainter {
  final SnakeGame game;
  SnakePainter(this.game);

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / game.width;
    final cellHeight = size.height / game.height;
    final foodPaint = Paint()..color = Colors.red;
    canvas.drawRect(Rect.fromLTWH(game.foodX * cellWidth, game.foodY * cellHeight, cellWidth, cellHeight), foodPaint);
    final snakePaint = Paint()..color = Colors.green;
    for (final segment in game.snake) {
      canvas.drawRect(Rect.fromLTWH(segment.x * cellWidth, segment.y * cellHeight, cellWidth, cellHeight), snakePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Pong Game Screen
class PongGameScreen extends StatefulWidget {
  const PongGameScreen({super.key});

  @override
  State<PongGameScreen> createState() => _PongGameScreenState();
}

class _PongGameScreenState extends State<PongGameScreen> {
  final PongGame _game = PongGame();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _startGameLoop();
  }

  void _startGameLoop() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted && _isPlaying && !_game.isGameOver) {
        _game.aiMove();
        _game.update();
        if (mounted) setState(() {});
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(backgroundColor: const Color(0xFF0A0E14), title: Text('Pong - ${_game.leftScore} : ${_game.rightScore}', style: const TextStyle(color: Color(0xFF00D4AA)))),
      body: Column(
        children: [
          Expanded(child: Center(child: Container(width: 300, height: 200, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF00D4AA))), child: CustomPaint(painter: PongPainter(_game))))),
          if (!_isPlaying || _game.isGameOver)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)),
                onPressed: () { setState(() { _game.reset(); _isPlaying = true; _startGameLoop(); }); },
                child: Text(_game.isGameOver ? 'Play Again' : 'Start Game'),
              ),
            ),
        ],
      ),
    );
  }
}

class PongPainter extends CustomPainter {
  final PongGame game;
  PongPainter(this.game);

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / game.width;
    final cellHeight = size.height / game.height;
    final ballPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(game.ballX * cellWidth + cellWidth/2, game.ballY * cellHeight + cellHeight/2), 5, ballPaint);
    final paddlePaint = Paint()..color = const Color(0xFF00D4AA);
    canvas.drawRect(Rect.fromLTWH(game.leftPaddle.x * cellWidth, game.leftPaddle.y * cellHeight, cellWidth * game.leftPaddle.width, cellHeight * game.leftPaddle.height), paddlePaint);
    canvas.drawRect(Rect.fromLTWH(game.rightPaddle.x * cellWidth, game.rightPaddle.y * cellHeight, cellWidth * game.rightPaddle.width, cellHeight * game.rightPaddle.height), paddlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Wordle Game Screen
class WordleGameScreen extends StatefulWidget {
  const WordleGameScreen({super.key});

  @override
  State<WordleGameScreen> createState() => _WordleGameScreenState();
}

class _WordleGameScreenState extends State<WordleGameScreen> {
  final WordleGame _game = WordleGame();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(backgroundColor: const Color(0xFF0A0E14), title: Text(_game.isGameOver ? (_game.isWon ? '🎉 You Won!' : 'Game Over') : 'Wordle', style: const TextStyle(color: Color(0xFF00D4AA)))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Hint: ${_game.getHint()}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: WordleGame.maxAttempts,
                itemBuilder: (context, attempt) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(WordleGame.wordLength, (i) {
                      final letter = _game.attempts[attempt][i];
                      final state = _game.letterStates[attempt][i];
                      return Container(
                        width: 50, height: 50, margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: _getStateColor(state), border: Border.all(color: state == LetterState.unknown ? Colors.grey : Colors.transparent)),
                        child: Center(child: Text(letter, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: state == LetterState.unknown ? Colors.white : Colors.black))),
                      );
                    }),
                  );
                },
              ),
            ),
            if (!_game.isGameOver) ...[
              TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Enter 5-letter word', hintStyle: TextStyle(color: Colors.grey)), style: const TextStyle(color: Colors.white), maxLength: 5, textCapitalization: TextCapitalization.characters),
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA)), onPressed: () { if (_controller.text.length == 5) { setState(() { _game.makeGuess(_controller.text); _controller.clear(); }); }}, child: const Text('Guess')),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStateColor(LetterState state) {
    switch (state) {
      case LetterState.correct: return Colors.green;
      case LetterState.present: return Colors.orange;
      case LetterState.absent: return Colors.grey;
      case LetterState.unknown: return const Color(0xFF1E1E1E);
    }
  }
}