/// Memory Match Game Implementation
library;

/// Card state
enum CardState {
  hidden,
  revealed,
  matched,
}

/// Memory card
class MemoryCard {
  final int id;
  final String symbol;
  CardState state;
  int? matchId;
  
  MemoryCard({
    required this.id,
    required this.symbol,
    this.state = CardState.hidden,
    this.matchId,
  });
}

/// Memory Match Game
class MemoryMatchGame {
  final List<MemoryCard> cards = [];
  final int gridSize; // 4x4 = 16 cards
  int moves = 0;
  int matches = 0;
  String? firstSelected;
  String? secondSelected;
  bool isChecking = false;
  bool isGameOver = false;
  
  // Emoji symbols for cards
  static const List<String> symbols = [
    '🍎', '🍊', '🍋', '🍇', '🍓', '🍒', '🥝', '🍑',
  ];
  
  MemoryMatchGame({this.gridSize = 4}) {
    _initCards();
  }
  
  void _initCards() {
    // Create pairs
    final pairs = gridSize * gridSize ~/ 2;
    final selectedSymbols = symbols.take(pairs).toList();
    
    // Create two of each
    final cardSymbols = [...selectedSymbols, ...selectedSymbols];
    cardSymbols.shuffle();
    
    for (int i = 0; i < cardSymbols.length; i++) {
      cards.add(MemoryCard(
        id: i,
        symbol: cardSymbols[i],
      ));
    }
  }
  
  /// Flip a card
  bool flipCard(int cardId) {
    if (isChecking || isGameOver) return false;
    
    final card = cards.firstWhere((c) => c.id == cardId);
    if (card.state != CardState.hidden) return false;
    
    card.state = CardState.revealed;
    
    if (firstSelected == null) {
      firstSelected = card.symbol;
    } else {
      secondSelected = card.symbol;
      moves++;
      _checkMatch();
    }
    
    return true;
  }
  
  void _checkMatch() {
    isChecking = true;
    
    final revealedCards = cards.where((c) => c.state == CardState.revealed).toList();
    
    if (revealedCards.length == 2) {
      final card1 = revealedCards[0];
      final card2 = revealedCards[1];
      
      if (card1.symbol == card2.symbol) {
        // Match found
        card1.state = CardState.matched;
        card2.state = CardState.matched;
        matches++;
        
        if (matches == gridSize * gridSize ~/ 2) {
          isGameOver = true;
        }
      } else {
        // No match - hide after delay
        Future.delayed(const Duration(milliseconds: 800), () {
          card1.state = CardState.hidden;
          card2.state = CardState.hidden;
          isChecking = false;
        });
        return;
      }
    }
    
    firstSelected = null;
    secondSelected = null;
    isChecking = false;
  }
  
  /// Get game state
  Map<String, dynamic> getState() {
    return {
      'cards': cards.map((c) => {
        'id': c.id,
        'symbol': c.state == CardState.hidden ? '?' : c.symbol,
        'state': c.state.name,
      }).toList(),
      'moves': moves,
      'matches': matches,
      'isGameOver': isGameOver,
    };
  }
  
  /// Reset game
  void reset() {
    cards.clear();
    moves = 0;
    matches = 0;
    firstSelected = null;
    secondSelected = null;
    isChecking = false;
    isGameOver = false;
    _initCards();
  }
}

// Demo
void main() {
  final game = MemoryMatchGame();
  
  print("Memory Match Demo");
  print("Find all matching pairs!");
  
  // Flip some cards
  game.flipCard(0);
  game.flipCard(1);
  
  print("Moves: ${game.moves}");
  print("Matches: ${game.matches}");
}