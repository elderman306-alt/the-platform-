/// Wordle Game Implementation
library;

/// Letter state
enum LetterState {
  unknown,
  correct,
  present,
  absent,
}

/// Wordle Game
class WordleGame {
  static const int wordLength = 5;
  static const int maxAttempts = 6;
  
  // Word list - common 5-letter words
  static const List<String> wordList = [
    'APPLE', 'BEACH', 'BRAIN', 'BREAD', 'BRIDGE', 'BROWN', 'CHAIR', 'CHEST', 
    'CHORD', 'CLICK', 'CLOCK', 'CLOUD', 'DANCE', 'DIARY', 'DRINK', 'DRIVE',
    'EARTH', 'FEAST', 'FIELD', 'FRUIT', 'GLASS', 'GRAPE', 'GREEN', 'GHOST',
    'HEART', 'HOUSE', 'JUICE', 'LIGHT', 'LEMON', 'MELON', 'MONEY', 'MUSIC',
    'NIGHT', 'OCEAN', 'PARTY', 'PIZZA', 'PHONE', 'PLANE', 'PLANT', 'PLATE',
    'POWER', 'RADIO', 'RIVER', 'ROBOT', 'SHIRT', 'SHOES', 'SMILE', 'SNAKE',
    'SPACE', 'SPOON', 'STORM', 'TABLE', 'TIGER', 'TOAST', 'TOUCH', 'TRACK',
    'TRAIN', 'TRUCK', 'VOICE', 'WATCH', 'WATER', 'WHALE', 'WORLD', 'WRITE',
    'YOUTH', 'ZEBRA',
  ];
  
  final String targetWord;
  int currentAttempt = 0;
  bool isGameOver = false;
  bool isWon = false;
  
  // Attempts history
  final List<List<String>> attempts = [];
  final List<List<LetterState>> letterStates = [];
  
  WordleGame() : targetWord = _getRandomWord() {
    for (int i = 0; i < maxAttempts; i++) {
      attempts.add(List.filled(wordLength, ''));
      letterStates.add(List.filled(wordLength, LetterState.unknown));
    }
  }
  
  static String _getRandomWord() {
    final index = DateTime.now().millisecondsSinceEpoch % wordList.length;
    return wordList[index];
  }
  
  /// Make a guess
  bool makeGuess(String guess) {
    if (isGameOver) return false;
    if (guess.length != wordLength) return false;
    
    final upperGuess = guess.toUpperCase();
    
    // Check if valid word (simplified - accept any 5 letters)
    if (!RegExp(r'^[A-Z]{5}$').hasMatch(upperGuess)) return false;
    
    // Record attempt
    final attemptLetters = upperGuess.split('');
    for (int i = 0; i < wordLength; i++) {
      attempts[currentAttempt][i] = attemptLetters[i];
      
      // Check letter state
      if (attemptLetters[i] == targetWord[i]) {
        letterStates[currentAttempt][i] = LetterState.correct;
      } else if (targetWord.contains(attemptLetters[i])) {
        letterStates[currentAttempt][i] = LetterState.present;
      } else {
        letterStates[currentAttempt][i] = LetterState.absent;
      }
    }
    
    // Check win
    if (upperGuess == targetWord) {
      isWon = true;
      isGameOver = true;
    }
    // Check loss
    else if (currentAttempt >= maxAttempts - 1) {
      isGameOver = true;
    }
    
    currentAttempt++;
    return true;
  }
  
  /// Get letter states for a specific attempt
  List<LetterState> getAttemptStates(int attempt) {
    return letterStates[attempt];
  }
  
  /// Get hint (first letter of target)
  String getHint() {
    return '${targetWord[0]}???'; // Show first letter
  }
  
  /// Get game state for display
  Map<String, dynamic> getState() {
    return {
      'attempts': attempts,
      'letterStates': letterStates.map((row) => 
        row.map((s) => s.name).toList()
      ).toList(),
      'currentAttempt': currentAttempt,
      'isGameOver': isGameOver,
      'isWon': isWon,
      'targetWord': isGameOver ? targetWord : null,
    };
  }
  
  /// Reset game
  void reset() {
    currentAttempt = 0;
    isGameOver = false;
    isWon = false;
    
    for (int i = 0; i < maxAttempts; i++) {
      for (int j = 0; j < wordLength; j++) {
        attempts[i][j] = '';
        letterStates[i][j] = LetterState.unknown;
      }
    }
  }
}

// Demo
void main() {
  final game = WordleGame();
  
  print("Wordle Game Demo");
  print("Target word: ${game.targetWord}");
  print("Hint: ${game.getHint()}");
  print("Max attempts: ${WordleGame.maxAttempts}");
  
  // Try some guesses
  game.makeGuess('APPLE');
  game.makeGuess('BRAIN');
  
  print("Current attempt: ${game.currentAttempt}");
  print("Game over: ${game.isGameOver}");
}