import 'dart:math';

/// Game status enum
enum GameStatus {
  waiting,
  active,
  completed,
  cancelled,
}

/// Game type enum
enum GameType {
  chess,
  battle,
  racing,
  puzzle,
  card,
}

/// Player model
class Player {
  final String id;
  final String name;
  final int score;
  final int wins;
  final int losses;
  final String rank;

  const Player({
    required this.id,
    required this.name,
    this.score = 0,
    this.wins = 0,
    this.losses = 0,
    this.rank = 'Bronze',
  });

  Player copyWith({
    String? id,
    String? name,
    int? score,
    int? wins,
    int? losses,
    String? rank,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      rank: rank ?? this.rank,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'score': score,
        'wins': wins,
        'losses': losses,
        'rank': rank,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        score: json['score'] as int? ?? 0,
        wins: json['wins'] as int? ?? 0,
        losses: json['losses'] as int? ?? 0,
        rank: json['rank'] as String? ?? 'Bronze',
      );
}

/// Game session model
class GameSession {
  final String id;
  final GameType type;
  final GameStatus status;
  final List<Player> players;
  final Player? winner;
  final DateTime createdAt;
  final DateTime? completedAt;

  const GameSession({
    required this.id,
    required this.type,
    this.status = GameStatus.waiting,
    required this.players,
    this.winner,
    required this.createdAt,
    this.completedAt,
  });

  GameSession copyWith({
    String? id,
    GameType? type,
    GameStatus? status,
    List<Player>? players,
    Player? winner,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return GameSession(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      players: players ?? this.players,
      winner: winner ?? this.winner,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Game Service - manages game state and logic
class GameService {
  final List<GameSession> _activeGames = [];
  final List<Player> _players = [];
  final Random _random = Random();

  /// Get all active games
  List<GameSession> get activeGames => List.unmodifiable(_activeGames);

  /// Get all players
  List<Player> get players => List.unmodifiable(_players);

  /// Create a new game session
  GameSession createGame(GameType type, List<Player> players) {
    final gameId = _generateGameId();
    final session = GameSession(
      id: gameId,
      type: type,
      status: GameStatus.waiting,
      players: players,
      createdAt: DateTime.now(),
    );
    _activeGames.add(session);
    return session;
  }

  /// Start a game
  GameSession startGame(String gameId) {
    final index = _activeGames.indexWhere((g) => g.id == gameId);
    if (index == -1) throw Exception('Game not found');

    final game = _activeGames[index];
    if (game.players.length < 2) {
      throw Exception('Need at least 2 players to start');
    }

    _activeGames[index] = game.copyWith(status: GameStatus.active);
    return _activeGames[index];
  }

  /// Complete a game with winner
  GameSession completeGame(String gameId, Player winner) {
    final index = _activeGames.indexWhere((g) => g.id == gameId);
    if (index == -1) throw Exception('Game not found');

    final game = _activeGames[index];
    _activeGames[index] = game.copyWith(
      status: GameStatus.completed,
      winner: winner,
      completedAt: DateTime.now(),
    );

    // Update player stats
    _updatePlayerStats(winner, game.players);

    return _activeGames[index];
  }

  /// Update player stats after game
  void _updatePlayerStats(Player winner, List<Player> players) {
    for (final player in players) {
      final idx = _players.indexWhere((p) => p.id == player.id);
      if (idx != -1) {
        final isWinner = player.id == winner.id;
        final updatedPlayer = player.copyWith(
          wins: isWinner ? player.wins + 1 : player.wins,
          losses: isWinner ? player.losses : player.losses + 1,
          score: player.score + (isWinner ? 25 : 10),
          rank: _calculateRank(player.score + (isWinner ? 25 : 10)),
        );
        _players[idx] = updatedPlayer;
      }
    }
  }

  /// Calculate rank based on score
  String _calculateRank(int score) {
    if (score >= 2500) return 'Diamond';
    if (score >= 2000) return 'Platinum';
    if (score >= 1500) return 'Gold';
    if (score >= 1000) return 'Silver';
    if (score >= 500) return 'Bronze';
    return 'Newcomer';
  }

  /// Generate unique game ID
  String _generateGameId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  /// Get player by ID
  Player? getPlayer(String id) {
    try {
      return _players.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Add or update player
  void addPlayer(Player player) {
    final idx = _players.indexWhere((p) => p.id == player.id);
    if (idx != -1) {
      _players[idx] = player;
    } else {
      _players.add(player);
    }
  }

  /// Get game by ID
  GameSession? getGame(String id) {
    try {
      return _activeGames.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }
}