# 🤖 AI #4: COMMUNICATION
## Branch: ai4-communication

---

### YOUR TASK
Build the Chat, Voice, and Video Communication system.

---

### 1️⃣ CHAT SYSTEM

**Features:**
- WhatsApp-style UI
- E2E encrypted messages
- Messages fragmented + stored on P2P network
- No phone number required
- Find user by PINC ID

---

### 2️⃣ VOICE & VIDEO CALLS

**Core Feature: Caller Pays, Receiver Needs No Internet**
```
- User A (has data) calls User B (no internet)
- App establishes P2P tunnel using A's connection
- Traffic FILTERED: voice/video packets ONLY
- Adaptive bitrate:
  - Voice: 8-64 kbps
  - Video: 128 kbps - 2 Mbps
- Caller pays for BOTH
- Minimum: 32 kbps voice, 256 kbps video
```

---

### 3️⃣ SCREEN SHARING

- Encrypted stream via P2P mesh
- Adaptive bitrate based on bandwidth
- Host controls

---

### 4️⃣ GROUP CALLS

- Up to 50 participants
- Host controls
- Encrypted multicast via mesh

---

### 📁 FILE STRUCTURE
```
lib/
  features/
    communication/
      chat/
        data/
        domain/
        presentation/
      calls/
        data/
        domain/
        presentation/
```

---

### 🔧 IMPLEMENTATION

**Chat:**
1. `chat_service.dart` - Message handling
2. `encryption.dart` - E2E encryption
3. `chat_screen.dart` - UI
4. `message_bubble.dart` - Widget

**Calls:**
1. `call_tunnel_manager.dart` - P2P tunnel
2. `webrtc_service.dart` - WebRTC setup
3. `voice_call_screen.dart`
4. `video_call_screen.dart`
5. `screen_share_screen.dart`

---

### 🥅 IMPLEMENTATION RULES

**No Internet Calls:**
- Use sender's connection via P2P tunnel
- Traffic filtered - call packets ONLY
- No browsing, no downloads allowed

**Cost Display:**
- Show real-time cost: "This call costs ~X PINC/min"
- Deduct from caller as call progresses

---

### ✅ COMPLETE CHECKLIST

- [ ] Chat UI + E2E encryption
- [ ] Voice calls (no internet)
- [ ] Video calls (no internet)
- [ ] Screen sharing
- [ ] Find user by PINC ID
- [ ] Group calls (up to 50)
- [ ] Cost display

---

### 🎯 WHEN READY

**Instruction to paste to AI #4:**
```
Go to branch: ai4-communication
Create your branch and implement:
- Chat (E2E encrypted)
- Voice calls (no internet)
- Video calls (no internet)
- Screen sharing
- Caller pays system
```

---

*AI #4: Communication - Connect without limits*