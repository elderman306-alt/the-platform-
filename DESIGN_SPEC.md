# 🎨 PINC NETWORK - DESIGN SPECIFICATION

---

## 📱 APP BRAND IDENTITY

### Primary Colors
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Primary** | `#00D4AA` | Main accent, buttons, highlights |
| **Primary Dark** | `#00A080` | Pressed states, headers |
| **Primary Light** | `#40FFCE` | Backgrounds, cards |
| **Background** | `#0A0A0F` | Main background (dark) |
| **Surface** | `#151520` | Cards, dialogs |
| **Surface Light** | `#1E1E2E` | Input fields |
| **Text Primary** | `#FFFFFF` | Main text |
| **Text Secondary** | `#A0A0B0` | Subtitles, hints |
| **Error** | `#FF4444` | Errors, warnings |
| **Success** | `#00FF88` | Success states |

### PINC Coin Colors
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Coin Gold** | `#FFD700` | Coin icon, values |
| **Coin Light** | `#FFF8DC` | Highlights |
| **Coin Gradient Start** | `#FFD700` | Coin gradient |
| **Coin Gradient End** | `#FFA500` | Coin gradient |

---

## 🖼️ LOGO DESIGN

### App Logo
```
      ■■■■■■■
    ■■        ■■
   ■■    PINC   ■■
    ■■        ■■
      ■■■■■■■
         ↓
    ═══════════
```

### Logo Specifications:
- **Style**: Geometric, modern, crypto-inspired
- **Shape**: Hexagonal/diamond shape
- **Colors**: Primary (#00D4AA) with gold (#FFD700) accent
- **Meaning**: "PINC" = Private Independent Network Coin

### Coin Icon:
- Circular with "P" symbol
- Gold gradient
- Size: 48x48 for display, 24x24 for inline

---

## 📐 APP STRUCTURE

### Navigation: 7 Tabs
```
┌─────────────────────────────────────────┐
│              [Status Bar]               │
├─────────────────────────────────────────┤
│              [App Bar]                  │
│         PINC Network                    │
├─────────────────────────────────────────┤
│  [Home] [ID] [P2P] [Chat] [Wallet] [Game] [Jobs] │
├─────────────────────────────────────────┤
│                                         │
│            [Content Area]               │
│                                         │
│                                         │
├─────────────────────────────────────────┤
│         [Bottom Navigation]             │
└─────────────────────────────────────────┘
```

### Tab Icons:
| Tab | Icon | Color |
|-----|------|-------|
| Home | 🏠 House | #00D4AA |
| Identity | 🔐 Shield | #00D4AA |
| P2P | 🌐 Network | #00D4AA |
| Chat | 💬 Bubble | #00D4AA |
| Wallet | 💰 Coin | #FFD700 |
| Gaming | 🎮 Controller | #00D4AA |
| Jobs | 💼 Briefcase | #00D4AA |

---

## 🎮 GAME VISUALS - HIGH QUALITY REQUIREMENTS

### Connect 4
- **Board**: 7x6 grid with 3D effect
- **Pieces**: Red (#FF4444) and Yellow (#FFD700) with shadows
- **Animations**: Drop animation, win celebration
- **Quality**: Anti-aliased, smooth 60fps

### Tic Tac Toe
- **Grid**: Clean lines with glow effect
- **X**: Blue (#00D4FF) with animation
- **O**: Gold (#FFD700) with animation
- **Win**: Glowing line through winner

### Memory
- **Cards**: Flipping animation (3D transform)
- **Icons**: High-quality SVG icons
- **Matched**: Green glow + scale animation
- **Background**: Subtle pattern

### Snake
- **Snake**: Gradient green (#00D4AA → #00FF88)
- **Food**: Red apple with glow
- **Grid**: Subtle dotted pattern
- **Speed**: Smooth movement

### Pong
- **Paddles**: Gradient blue (#00D4AA)
- **Ball**: White with trail effect
- **Score**: Large, bold typography
- **Effects**: Particle on hit

### Wordle
- **Tiles**: Color-coded feedback
  - Correct: Green (#00FF88)
  - Present: Yellow (#FFD700)
  - Absent: Gray (#404040)
- **Keyboard**: On-screen with color hints
- **Animations**: Flip and pop

---

## 🔤 TYPOGRAPHY

### Font Family
- **Primary**: Roboto (system default)
- **Headings**: Roboto Bold
- **Body**: Roboto Regular
- **Monospace**: Roboto Mono (for codes)

### Font Sizes
| Element | Size | Weight |
|---------|------|--------|
| App Title | 24sp | Bold |
| Screen Title | 20sp | Bold |
| Section Header | 18sp | SemiBold |
| Body | 16sp | Regular |
| Caption | 14sp | Regular |
| Small | 12sp | Regular |

---

## 📱 COMPONENT STYLES

### Buttons
```
Primary Button:
- Background: #00D4AA
- Text: #FFFFFF
- Radius: 12px
- Padding: 16px horizontal, 12px vertical
- Shadow: 0 4px 12px rgba(0, 212, 170, 0.3)

Secondary Button:
- Background: Transparent
- Border: 1px #00D4AA
- Text: #00D4AA
- Radius: 12px
```

### Cards
```
- Background: #151520
- Radius: 16px
- Padding: 16px
- Shadow: 0 4px 20px rgba(0, 0, 0, 0.3)
- Border: 1px solid #252530
```

### Input Fields
```
- Background: #1E1E2E
- Border: 1px solid #303040
- Focus Border: #00D4AA
- Radius: 12px
- Padding: 16px
```

---

## 🌙 DARK THEME

### Complete Theme:
```dart
const AppTheme = {
  primaryColor: Color(0xFF00D4AA),
  primaryColorDark: Color(0xFF00A080),
  primaryColorLight: Color(0xFF40FFCE),
  backgroundColor: Color(0xFF0A0A0F),
  surfaceColor: Color(0xFF151520),
  surfaceLightColor: Color(0xFF1E1E2E),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFA0A0B0),
  errorColor: Color(0xFFFF4444),
  successColor: Color(0xFF00FF88),
  coinGold: Color(0xFFFFD700),
}
```

---

## 📋 SCREEN LAYOUTS

### Home Screen
- Welcome banner with PINC balance
- Quick actions (Send, Receive, Scan)
- Recent transactions
- Feature highlights

### Identity Screen
- PINC ID card (prominent)
- Security level indicator
- Biometric status
- Settings shortcuts

### P2P Screen
- Network status
- Connected nodes count
- Storage usage
- Enable/disable toggle

### Chat Screen
- Conversation list
- Message bubbles (sent/received)
- Input field with send button
- Voice call button
- Video call button

### Financial Screen
- Large PINC balance display
- Send/Receive buttons
- QR code display
- Transaction history
- Scan QR button

### Gaming Screen
- Game selection grid
- Featured game banner
- Leaderboard preview
- Tournament status

### Jobs Screen
- Job categories
- Posted jobs list
- My bids tab
- Post job button

---

## ⚡ ANIMATIONS

### Global:
- Page transitions: Fade + Slide (300ms)
- Button press: Scale 0.95 (100ms)
- Card tap: Scale 1.02 (150ms)
- Loading: Pulsing PINC logo

### Game-Specific:
- Win celebration: Confetti + sound
- Move: Smooth interpolation
- Match: Glow + bounce

---

## ✅ VERIFICATION CHECKLIST

- [ ] Logo created and used in app
- [ ] Brand colors applied consistently
- [ ] Dark theme implemented
- [ ] All screens styled consistently
- [ ] Games have high-quality visuals
- [ ] Animations smooth (60fps)
- [ ] Typography consistent
- [ ] Icons match brand
- [ ] Responsive design works

---

*DESIGN SPEC - VERIFIED*