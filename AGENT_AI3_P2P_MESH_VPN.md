# 🤖 AI #3: P2P MESH VPN
## Branch: ai3-p2p-mesh-vpn

---

### YOUR TASK
Build the Internet Sharing (PINC Net) system using mesh networking.

---

### 1️⃣ CORE FEATURES

**P2P Mesh VPN:**
- Share internet peer-to-peer
- No centralized servers
- Device-to-device connection
- IP preservation (Ghost Origin)

---

### 2️⃣ SELLER SYSTEM

**Seller Features:**
- Subscription: 435 PINC/month to sell
- Free tier: 3 users max
- Premium: +325 PINC → 10 users
- Set price per: speed, users, time
- SLA: 87% uptime + 87% speed required

**SLA Rules:**
- < 76% three times = auto-delist
- Uptime tracking
- Speed verification

---

### 3️⃣ BUYER SYSTEM

**Buyer Features:**
- Browse available sellers
- View real capacity
- Connect via P2P tunnel
- Auto-refund if SLA not met

---

### 4️⃣ ESCROW SYSTEM

**Payment Flow:**
1. User pays → funds held in escrow
2. Session active
3. Session ends → verify SLA
4. Release to seller OR refund user

---

### 📁 FILE STRUCTURE
```
lib/
  features/
    pinc_net/
      data/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        screens/
        widgets/
```

---

### 🔧 IMPLEMENTATION

**Key Components:**

1. `lib/features/pinc_net/data/models/`
   - Seller model (price, capacity, SLA)
   - Buyer model
   - Session model (duration, data used)

2. `lib/features/pinc_net/domain/`
   - Connect to mesh network
   - SLA verification
   - Dynamic pricing engine

3. `lib/features/pinc_net/presentation/`
   - Seller dashboard
   - Buyer browser
   - Connection screen

---

### 💰 PRICING STRUCTURE

| Tier | Price | Users |
|------|-------|-------|
| Free | 0 PINC | 3 |
| Premium | +325 PINC | 10 |
| Seller sub | 435 PINC/month | unlimited buyers |

---

### ✅ COMPLETE CHECKLIST

- [ ] Mesh network setup
- [ ] Seller dashboard
- [ ] Buyer browser
- [ ] SLA tracking
- [ ] Dynamic pricing
- [ ] Escrow + refund
- [ ] Connection management

---

### 🎯 WHEN READY

**Instruction to paste to AI #3:**
```
Go to branch: ai3-p2p-mesh-vpn
Create your branch and implement:
- Mesh networking
- Seller system (435 PINC/month)
- Buyer system
- SLA enforcement
- Escrow + refund
```

---

*AI #3: P2P Mesh VPN - Internet for everyone, everywhere*