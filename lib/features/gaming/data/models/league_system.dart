import 'dart:math';

/// League system - 50 players per league
class LeagueService {
  static const int playersPerLeague = 50;
  static const int divisions = 5;
  
  final Map<String, LeaguePlayer> _players = {};
  final List<League> _leagues = [];
  final Random _random = Random();

  /// Get all leagues
  List<League> get leagues => List.unmodifiable(_leagues);

  /// Initialize leagues with players
  void initializeLeagues() {
    _leagues.clear();
    
    for (int i = 0; i < divisions; i++) {
      final league = League(
        id: 'league_${i + 1}',
        name: _getLeagueName(i),
        division: i + 1,
        players: [],
      );
      
      // Add 50 players per league
      for (int j = 0; j < playersPerLeague; j++) {
        final player = LeaguePlayer(
          id: 'p_${i}_$j',
          name: 'Player_${i}_$j',
          rank: j + 1,
          points: (playersPerLeague - j) * 100,
          wins: _random.nextInt(50),
          losses: _random.nextInt(30),
        );
        league.players.add(player);
        _players[player.id] = player;
      }
      
      _leagues.add(league);
    }
  }

  String _getLeagueName(int division) {
    switch (division) {
      case 0: return 'Diamond League';
      case 1: return 'Platinum League';
      case 2: return 'Gold League';
      case 3: return 'Silver League';
      case 4: return 'Bronze League';
      default: return 'League ${division + 1}';
    }
  }

  /// Get player in league
  LeaguePlayer? getPlayer(String playerId) => _players[playerId];

  /// Update player after match
  void updatePlayerStats(String playerId, bool won, int pointsEarned) {
    final player = _players[playerId];
    if (player == null) return;

    final updatedPlayer = player.copyWith(
      wins: won ? player.wins + 1 : player.wins,
      losses: won ? player.losses : player.losses + 1,
      points: player.points + pointsEarned,
    );
    _players[playerId] = updatedPlayer;

    // Update league rankings
    for (final league in _leagues) {
      final idx = league.players.indexWhere((p) => p.id == playerId);
      if (idx != -1) {
        league.players[idx] = updatedPlayer;
        // Re-sort by points
        league.players.sort((a, b) => b.points.compareTo(a.points));
        // Update ranks
        for (int i = 0; i < league.players.length; i++) {
          league.players[i] = league.players[i].copyWith(rank: i + 1);
        }
        break;
      }
    }
  }

  /// Get top players from league
  List<LeaguePlayer> getTopPlayers(String leagueId, {int limit = 10}) {
    final league = _leagues.firstWhere(
      (l) => l.id == leagueId,
      orElse: () => _leagues.first,
    );
    return league.players.take(limit).toList();
  }
}

/// League model
class League {
  final String id;
  final String name;
  final int division;
  final List<LeaguePlayer> players;

  const League({
    required this.id,
    required this.name,
    required this.division,
    required this.players,
  });
}

/// League player model
class LeaguePlayer {
  final String id;
  final String name;
  final int rank;
  final int points;
  final int wins;
  final int losses;

  const LeaguePlayer({
    required this.id,
    required this.name,
    required this.rank,
    required this.points,
    required this.wins,
    required this.losses,
  });

  double get winRate => wins + losses > 0 ? wins / (wins + losses) * 100 : 0;

  LeaguePlayer copyWith({
    String? id,
    String? name,
    int? rank,
    int? points,
    int? wins,
    int? losses,
  }) {
    return LeaguePlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      rank: rank ?? this.rank,
      points: points ?? this.points,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
    );
  }
}

/// Wager service - min 20 PINC
class WagerService {
  static const int minWager = 20;
  final Map<String, Wager> _wagers = {};
  int _wagerIdCounter = 0;

  /// Create a new wager
  Wager createWager({
    required String creatorId,
    required int amount,
    required String gameType,
  }) {
    if (amount < minWager) {
      throw Exception('Minimum wager is $minWager PINC');
    }

    final wager = Wager(
      id: 'wager_${++_wagerIdCounter}',
      creatorId: creatorId,
      amount: amount,
      gameType: gameType,
      status: WagerStatus.pending,
      createdAt: DateTime.now(),
    );

    _wagers[wager.id] = wager;
    return wager;
  }

  /// Accept a wager
  Wager acceptWager(String wagerId, String opponentId) {
    final wager = _wagers[wagerId];
    if (wager == null) throw Exception('Wager not found');
    if (wager.status != WagerStatus.pending) throw Exception('Wager not available');

    _wagers[wagerId] = wager.copyWith(
      opponentId: opponentId,
      status: WagerStatus.active,
    );
    return _wagers[wagerId]!;
  }

  /// Complete wager - winner gets amount * 2 (minus house fee)
  Wager completeWager(String wagerId, String winnerId) {
    final wager = _wagers[wagerId];
    if (wager == null) throw Exception('Wager not found');

    const houseFee = 0.05; // 5% house fee
    final prize = (wager.amount * 2 * (1 - houseFee)).round();

    _wagers[wagerId] = wager.copyWith(
      winnerId: winnerId,
      prize: prize,
      status: WagerStatus.completed,
      completedAt: DateTime.now(),
    );
    return _wagers[wagerId]!;
  }

  /// Cancel wager
  Wager cancelWager(String wagerId) {
    final wager = _wagers[wagerId];
    if (wager == null) throw Exception('Wager not found');

    _wagers[wagerId] = wager.copyWith(status: WagerStatus.cancelled);
    return _wagers[wagerId]!;
  }

  /// Get active wagers
  List<Wager> getActiveWagers() {
    return _wagers.values.where((w) => w.status == WagerStatus.pending).toList();
  }

  /// Get wager by ID
  Wager? getWager(String id) => _wagers[id];
}

/// Wager model
enum WagerStatus { pending, active, completed, cancelled }

class Wager {
  final String id;
  final String creatorId;
  final String? opponentId;
  final int amount;
  final String gameType;
  final WagerStatus status;
  final String? winnerId;
  final int? prize;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Wager({
    required this.id,
    required this.creatorId,
    this.opponentId,
    required this.amount,
    required this.gameType,
    required this.status,
    this.winnerId,
    this.prize,
    required this.createdAt,
    this.completedAt,
  });

  Wager copyWith({
    String? id,
    String? creatorId,
    String? opponentId,
    int? amount,
    String? gameType,
    WagerStatus? status,
    String? winnerId,
    int? prize,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Wager(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      opponentId: opponentId ?? this.opponentId,
      amount: amount ?? this.amount,
      gameType: gameType ?? this.gameType,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      prize: prize ?? this.prize,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}