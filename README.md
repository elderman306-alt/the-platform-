# the-next
## AI #6 - Gaming Module

This branch contains the gaming component for The Platform project.

### Gaming Features
- Real-time multiplayer game support
- Game state management
- Leaderboard system
- Tournament system

### Phase 3 Implementation (6 Built-in Games)
- **Connect 4** - Classic vertical checkers
- **Tic Tac Toe** - 3x3 grid game
- **Memory** - Card matching game
- **Snake** - Classic snake game
- **Pong** - Two-player paddle game
- **Wordle** - 5-letter word guessing

### League System
- 5 Divisions: Diamond, Platinum, Gold, Silver, Bronze
- 50 players per league
- Ranking by points

### Wager System
- Minimum wager: 20 PINC
- 5% house fee on winnings
- P2P wager challenges

### Implementation
- `lib/features/gaming/data/models/game_models.dart` - Game session and player models
- `lib/features/gaming/data/models/tournament_models.dart` - Tournament and leaderboard models
- `lib/features/gaming/data/models/builtin_games.dart` - 6 built-in game implementations
- `lib/features/gaming/data/models/league_system.dart` - League and wager system
- `lib/features/gaming/data/gaming_service.dart` - Core gaming service
