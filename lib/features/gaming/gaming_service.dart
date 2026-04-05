/// Gaming Service - Main service for all gaming features
library;

/// Game types available in the platform
enum GameType {
  connect4,
  tictactoe,
  memoryMatch,
  snake,
  pong,
  wordle,
}

/// Game result
class GameResult {
  final String gameId;
  final GameType gameType;
  final String player1Id;
  final String? player2Id;
  final String? winnerId;
  final bool isDraw;
  final int player1Score;
  final int player2Score;
  final DateTime playedAt;
  final int? wagerPinc;

  GameResult({
    required this.gameId,
    required this.gameType,
    required this.player1Id,
    this.player2Id,
    this.winnerId,
    this.isDraw = false,
    this.player1Score = 0,
    this.player2Score = 0,
    required this.playedAt,
    this.wagerPinc,
  });
}

/// League entry
class LeagueEntry {
  final String oderId;
  final String odlerName;
  final int rank;
  final int points;
  final int wins;
  final int losses;
  final int gamesPlayed;

  LeagueEntry({
    required this.oderId,
    required this.odlerName,
    required this.rank,
    required this.points,
    required this.wins,
    required this.losses,
    required this.gamesPlayed,
  });
}

/// Wager request
class WagerRequest {
  final String requestId;
  final String creatorId;
  final GameType gameType;
  final int wagerAmount;
  final String? challengerId;
  final WagerStatus status;
  final DateTime createdAt;

  WagerRequest({
    required this.requestId,
    required this.creatorId,
    required this.gameType,
    required this.wagerAmount,
    this.challengerId,
    required this.status,
    required this.createdAt,
  });
}

enum WagerStatus {
  open,
  accepted,
  completed,
  cancelled,
}

/// Tournament
class Tournament {
  final String tournamentId;
  final String name;
  final GameType gameType;
  final int maxPlayers;
  final int currentPlayers;
  final TournamentStatus status;
  final DateTime startDate;
  final int prizePool;
  final String winnerId;

  Tournament({
    required this.tournamentId,
    required this.name,
    required this.gameType,
    required this.maxPlayers,
    this.currentPlayers = 0,
    required this.status,
    required this.startDate,
    required this.prizePool,
    this.winnerId = "",
  });
}

enum TournamentStatus {
  upcoming,
  inProgress,
  completed,
}

/// Gaming service
class GamingService {
  final Map<String, List<GameResult>> _gameHistory = {};
  final List<LeagueEntry> _league = [];
  final List<WagerRequest> _wagerRequests = [];
  final List<Tournament> _tournaments = [];
  
  int _gameIdCounter = 0;
  int _wagerIdCounter = 0;
  int _tournamentIdCounter = 0;

  /// Get all games for a player
  List<GameResult> getGameHistory(String oderId) {
    return _gameHistory[oderId] ?? [];
  }

  /// Record a game result
  GameResult recordGameResult({
    required GameType gameType,
    required String player1Id,
    String? player2Id,
    String? winnerId,
    bool isDraw = false,
    int player1Score = 0,
    int player2Score = 0,
    int? wagerPinc,
  }) {
    _gameIdCounter++;
    final result = GameResult(
      gameId: "game_$_gameIdCounter",
      gameType: gameType,
      player1Id: player1Id,
      player2Id: player2Id,
      winnerId: winnerId,
      isDraw: isDraw,
      player1Score: player1Score,
      player2Score: player2Score,
      playedAt: DateTime.now(),
      wagerPinc: wagerPinc,
    );

    // Add to player history
    _gameHistory[player1Id] = [...(_gameHistory[player1Id] ?? []), result];
    if (player2Id != null) {
      _gameHistory[player2Id] = [...(_gameHistory[player2Id] ?? []), result];
    }

    // Update league if ranked
    if (winnerId != null) {
      _updateLeague(winnerId, player1Id, isDraw);
    }

    return result;
  }

  /// Create a wager request
  WagerRequest createWager({
    required String creatorId,
    required GameType gameType,
    required int wagerAmount,
  }) {
    _wagerIdCounter++;
    return WagerRequest(
      requestId: "wager_$_wagerIdCounter",
      creatorId: creatorId,
      gameType: gameType,
      wagerAmount: wagerAmount,
      status: WagerStatus.open,
      createdAt: DateTime.now(),
    );
  }

  /// Accept a wager
  WagerRequest acceptWager(String wagerId, String challengerId) {
    final index = _wagerRequests.indexWhere((w) => w.requestId == wagerId);
    if (index != -1) {
      final wager = _wagerRequests[index];
      _wagerRequests[index] = WagerRequest(
        requestId: wager.requestId,
        creatorId: wager.creatorId,
        gameType: wager.gameType,
        wagerAmount: wager.wagerAmount,
        challengerId: challengerId,
        status: WagerStatus.accepted,
        createdAt: wager.createdAt,
      );
      return _wagerRequests[index];
    }
    throw Exception("Wager not found");
  }

  /// Get open wagers
  List<WagerRequest> getOpenWagers() {
    return _wagerRequests.where((w) => w.status == WagerStatus.open).toList();
  }

  /// Create a tournament
  Tournament createTournament({
    required String name,
    required GameType gameType,
    required int maxPlayers,
    required DateTime startDate,
    required int prizePool,
  }) {
    _tournamentIdCounter++;
    return Tournament(
      tournamentId: "tournament_$_tournamentIdCounter",
      name: name,
      gameType: gameType,
      maxPlayers: maxPlayers,
      status: TournamentStatus.upcoming,
      startDate: startDate,
      prizePool: prizePool,
    );
  }

  /// Get leaderboard
  List<LeagueEntry> getLeaderboard() {
    final sorted = List<LeagueEntry>.from(_league);
    sorted.sort((a, b) => b.points.compareTo(a.points));
    return sorted;
  }

  /// Get player rank
  int? getPlayerRank(String oderId) {
    final entry = _league.firstWhere(
      (e) => e.oderId == oderId,
      orElse: () => LeagueEntry(
        oderId: "",
        odlerName: "",
        rank: 0,
        points: 0,
        wins: 0,
        losses: 0,
        gamesPlayed: 0,
      ),
    );
    return entry.rank > 0 ? entry.rank : null;
  }

  void _updateLeague(String winnerId, String loserId, bool isDraw) {
    // Update winner
    _updateEntry(winnerId, isDraw ? 1 : 3, true);
    // Update loser
    _updateEntry(loserId, 0, false);
  }

  void _updateEntry(String oderId, int pointsToAdd, bool isWin) {
    final index = _league.indexWhere((e) => e.oderId == oderId);
    if (index != -1) {
      final entry = _league[index];
      _league[index] = LeagueEntry(
        oderId: entry.oderId,
        odlerName: entry.odlerName,
        rank: entry.rank,
        points: entry.points + pointsToAdd,
        wins: isWin ? entry.wins + 1 : entry.wins,
        losses: !isWin ? entry.losses + 1 : entry.losses,
        gamesPlayed: entry.gamesPlayed + 1,
      );
    } else {
      _league.add(LeagueEntry(
        oderId: oderId,
        odlerName: oderId,
        rank: _league.length + 1,
        points: pointsToAdd,
        wins: isWin ? 1 : 0,
        losses: !isWin ? 1 : 0,
        gamesPlayed: 1,
      ));
    }
  }

  /// Calculate wager fee (7% + 5% creator)
  static int calculateWagerFee(int wagerAmount) {
    return (wagerAmount * 0.07).round() + (wagerAmount * 0.05).round();
  }
}