# 🤖 AI #9: CROSS-PLATFORM & UI
## Branch: ai9-cross-platform

---

### YOUR TASK
Build the Flutter UI and Cross-Platform support for THE PLATFORM.

---

### 1️⃣ UI STRUCTURE

**6 Tabs:**
1. **PINC Net** (Shield icon) - Internet sharing
2. **Wallet** (Wallet icon) - PINC coins
3. **Chat** (Chat icon) - Messages
4. **Jobs** (Work icon) - Freelance
5. **Games** (Game icon) - Play
6. **Profile** (Person icon) - Settings

---

### 2️⃣ THEME

**Dark Theme:**
| Element | Color |
|---------|-------|
| Primary | #00D4AA |
| Secondary | #7B61FF |
| Background | #0A0E14 |
| Surface | #131A24 |
| Error | #FF4757 |
| Warning | #FFBE0B |
| Text | #FFFFFF |
| Text Secondary | #8892A0 |

---

### 3️⃣ PLATFORM TARGETS

| Platform | Build Target | Notes |
|----------|------------|-------|
| Android | `.apk` / `.aab` | Primary |
| iOS | `.ipa` | Needs Mac |
| Windows | `.exe` | MinGW |
| Linux | `.deb` / `.rpm` / AppImage | Native |
| macOS | `.app` | Needs Mac |
| Android TV | APK | TV UI |

---

### 4️⃣ LOCALIZATION

**50+ Languages:**
- Auto-detect from location
- User override allowed
- Offline translation files

---

### 5️⃣ STORAGE

**Implementation:**
- Hive (local encrypted)
- IPFS (distributed)
- Fragmented encryption

---

### 📁 FILE STRUCTURE
```
lib/
  main.dart              # Entry point
  app.dart              # App setup
  core/
    theme.dart          # Dark theme
    constants.dart      # App constants
    routes.dart        # Navigation
  shared/
    widgets/          # Reusable widgets
    components/      # UI components
  features/
    pinc_net/
    wallet/
    chat/
    jobs/
    games/
    profile/
```

---

### 🔧 IMPLEMENTATION

**Main Entry:**
1. `lib/main.dart` - User app entry
2. `lib/main_admin.dart` - Admin entry (AI #8)

**Core:**
1. `theme.dart` - Dark theme + colors
2. `constants.dart` - App constants
3. `routes.dart` - Navigation

**Navigation:**
- Bottom navigation (6 tabs)
- MaterialApp with theme

---

### 🎨 UI COMPONENTS

**Create reusable:**
- `PrimaryButton`
- `SecondaryButton`
- `PincTextField`
- `PincCard`
- `LoadingIndicator`
- `ErrorDialog`

---

### ✅ COMPLETE CHECKLIST

- [ ] Flutter app setup
- [ ] Dark theme
- [ ] 6-tab navigation
- [ ] All feature screens
- [ ] Platform builds
- [ ] Localization
- [ ] Storage (Hive)

---

### 🎯 WHEN READY

**Instruction to paste to AI #9:**
```
Go to branch: ai9-cross-platform
Create your branch and implement:
- Flutter app (6 tabs)
- Dark theme
- All platform builds
- Localization
```

---

*AI #9: UI & Platforms - Beautiful on every device*