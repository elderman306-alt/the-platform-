# 🤖 AI #6: GAMING & CHALLENGES
## Branch: ai6-gaming

---

### YOUR TASK
Build the Games, Leagues, Challenges, and Wager system.

---

### 1️⃣ BUILT-IN GAMES (6)

| Game | Players | Implementation |
|------|---------|----------------|
| Connect 4 | 2 | Grid 7x6, gravity |
| Tic Tac Toe | 2 | 3x3 grid |
| Memory Match | 1 | Card flip matching |
| Snake | 1 | Classic snake |
| Pong | 1/2 | Classic pong |
| Wordle | 1 | 5-letter word guess |

---

### 2️⃣ EXTERNAL GAMES (4)

**Only these supported:**
| Game | Platform | Challenge |
|------|----------|-----------|
| PUBG Mobile/PC/PS | All | Most Kills, Best Survivor |
| PES / eFootball | All | Match Winner |
| FIFA | PS/Xbox | 1v1 Match |
| Mortal Kombat | All | Best-of-3/5 |

---

### 3️⃣ LEAGUE SYSTEM

**Features:**
- Up to 50 players per league
- Set entry fee
- Winner prizes by position (1st-10th)
- Auto-settlement

---

### 4️⃣ WAGER / BET SYSTEM

**P2P Wager:**
- User vs User
- Min wager: 20 PINC
- 7% platform + 5% creator

**Challenge:**
- Global broadcast
- Fee: 1,560 PINC
- 30-min notification to all

---

### 📁 FILE STRUCTURE
```
lib/
  features/
    gaming/
      built_in/
        connect4/
        tictactoe/
        memory/
        snake/
        pong/
        wordle/
      external/
      leagues/
      challenges/
```

---

### 🔧 IMPLEMENTATION

**Built-in Games:**
1. Each game in separate folder
2. `game_service.dart` - Game logic
3. `leauge_service.dart` - League management
4. `wager_service.dart` - Bet settlement

**UI:**
1. `games_screen.dart` - Game selection
2. `play_screen.dart` - In-game
3. `leagues_screen.dart`
4. `challenges_screen.dart`

---

### 🎮 IMPLEMENTATION RULES

**Game Logic:**
- Win detection
- Scoring system
- Timer support
- Move validation

**Anti-Forgery:**
- Cryptographic signatures
- P2P verification pool
- 3 random node consensus

---

### ✅ COMPLETE CHECKLIST

- [ ] Connect 4
- [ ] Tic Tac Toe
- [ ] Memory Match
- [ ] Snake
- [ ] Pong
- [ ] Wordle
- [ ] League system
- [ ] Wager system
- [ ] External games (PUBG/PES/FIFA/MK)

---

### 🎯 WHEN READY

**Instruction to paste to AI #6:**
```
Go to branch: ai6-gaming
Create your branch and implement:
- 6 built-in games
- League system
- Wager system
- External game monitoring
```

---

*AI #6: Gaming - Play to earn, compete to win*