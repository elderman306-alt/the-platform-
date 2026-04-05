import 'dart:math';

/// Tournament status
enum TournamentStatus {
  registration,
  active,
  completed,
  cancelled,
}

/// Tournament model
class Tournament {
  final String id;
  final String name;
  final String description;
  final String prize;
  final int maxPlayers;
  final int currentPlayers;
  final TournamentStatus status;
  final DateTime startDate;
  final List<String> playerIds;
  final String? winnerId;
  final double entryFee;

  const Tournament({
    required this.id,
    required this.name,
    this.description = '',
    required this.prize,
    required this.maxPlayers,
    this.currentPlayers = 0,
    this.status = TournamentStatus.registration,
    required this.startDate,
    this.playerIds = const [],
    this.winnerId,
    this.entryFee = 0,
  });

  Tournament copyWith({
    String? id,
    String? name,
    String? description,
    String? prize,
    int? maxPlayers,
    int? currentPlayers,
    TournamentStatus? status,
    DateTime? startDate,
    List<String>? playerIds,
    String? winnerId,
    double? entryFee,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      prize: prize ?? this.prize,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      playerIds: playerIds ?? this.playerIds,
      winnerId: winnerId ?? this.winnerId,
      entryFee: entryFee ?? this.entryFee,
    );
  }
}

/// Leaderboard entry
class LeaderboardEntry {
  final String playerId;
  final String playerName;
  final int rank;
  final int score;
  final int wins;
  final int losses;

  const LeaderboardEntry({
    required this.playerId,
    required this.playerName,
    required this.rank,
    required this.score,
    required this.wins,
    required this.losses,
  });

  double get winRate => wins + losses > 0 ? wins / (wins + losses) * 100 : 0;
}

/// Tournament Service - manages tournaments and leaderboard
class TournamentService {
  final List<Tournament> _tournaments = [];
  final Map<String, int> _playerScores = {};
  final Map<String, int> _playerWins = {};
  final Map<String, int> _playerLosses = {};
  final Random _random = Random();

  /// Get all active tournaments
  List<Tournament> get activeTournaments =>
      _tournaments.where((t) => t.status == TournamentStatus.active).toList();

  /// Get all registration open tournaments
  List<Tournament> get openTournaments => _tournaments
      .where((t) => t.status == TournamentStatus.registration)
      .toList();

  /// Get top players for leaderboard
  List<LeaderboardEntry> getLeaderboard({int limit = 10}) {
    final entries = <LeaderboardEntry>[];
    for (final playerId in _playerScores.keys) {
      entries.add(LeaderboardEntry(
        playerId: playerId,
        playerName: 'Player_$playerId', // Would be fetched from user service
        rank: 0,
        score: _playerScores[playerId] ?? 0,
        wins: _playerWins[playerId] ?? 0,
        losses: _playerLosses[playerId] ?? 0,
      ));
    }

    // Sort by score
    entries.sort((a, b) => b.score.compareTo(a.score));

    // Assign ranks
    for (var i = 0; i < entries.length; i++) {
      entries[i] = LeaderboardEntry(
        playerId: entries[i].playerId,
        playerName: entries[i].playerName,
        rank: i + 1,
        score: entries[i].score,
        wins: entries[i].wins,
        losses: entries[i].losses,
      );
    }

    return entries.take(limit).toList();
  }

  /// Create a new tournament
  Tournament createTournament({
    required String name,
    required String description,
    required String prize,
    required int maxPlayers,
    required DateTime startDate,
    double entryFee = 0,
  }) {
    final tournament = Tournament(
      id: _generateId(),
      name: name,
      description: description,
      prize: prize,
      maxPlayers: maxPlayers,
      startDate: startDate,
      entryFee: entryFee,
    );
    _tournaments.add(tournament);
    return tournament;
  }

  /// Register a player for tournament
  Tournament registerPlayer(String tournamentId, String playerId) {
    final index = _tournaments.indexWhere((t) => t.id == tournamentId);
    if (index == -1) throw Exception('Tournament not found');

    final tournament = _tournaments[index];
    if (tournament.currentPlayers >= tournament.maxPlayers) {
      throw Exception('Tournament is full');
    }
    if (tournament.playerIds.contains(playerId)) {
      throw Exception('Already registered');
    }

    final updatedTournament = tournament.copyWith(
      playerIds: [...tournament.playerIds, playerId],
      currentPlayers: tournament.currentPlayers + 1,
    );
    _tournaments[index] = updatedTournament;
    return updatedTournament;
  }

  /// Start a tournament
  Tournament startTournament(String tournamentId) {
    final index = _tournaments.indexWhere((t) => t.id == tournamentId);
    if (index == -1) throw Exception('Tournament not found');

    final tournament = _tournaments[index];
    if (tournament.currentPlayers < 2) {
      throw Exception('Need at least 2 players');
    }

    _tournaments[index] = tournament.copyWith(status: TournamentStatus.active);
    return _tournaments[index];
  }

  /// Complete a tournament
  Tournament completeTournament(String tournamentId, String winnerId) {
    final index = _tournaments.indexWhere((t) => t.id == tournamentId);
    if (index == -1) throw Exception('Tournament not found');

    final tournament = _tournaments[index];
    _tournaments[index] = tournament.copyWith(
      status: TournamentStatus.completed,
      winnerId: winnerId,
    );

    // Award points to winner
    _playerScores[winnerId] = (_playerScores[winnerId] ?? 0) + 500;

    return _tournaments[index];
  }

  /// Update player score
  void updatePlayerScore(String playerId, int score) {
    _playerScores[playerId] = (_playerScores[playerId] ?? 0) + score;
  }

  /// Record a win
  void recordWin(String playerId) {
    _playerWins[playerId] = (_playerWins[playerId] ?? 0) + 1;
  }

  /// Record a loss
  void recordLoss(String playerId) {
    _playerLosses[playerId] = (_playerLosses[playerId] ?? 0) + 1;
  }

  /// Get tournament by ID
  Tournament? getTournament(String id) {
    try {
      return _tournaments.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Generate unique ID
  String _generateId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
  }
}