# 🤖 AI #7: JOBS MARKETPLACE
## Branch: ai7-jobs

---

### YOUR TASK
Build the Remote Jobs Marketplace system.

---

### 1️⃣ POST JOB

**Features:**
- Title, description, budget, timeline
- Max workers setting
- 3% fee paid by employer

**Post Job Flow:**
1. Client creates job
2. Pays 3% fee upfront
3. Job posted to marketplace
4. Workers see and bid

---

### 2️⃣ BID SYSTEM

**Features:**
- Workers submit bids
- Client reviews and selects
- Free tier: 15 bids/month
- Premium: +300 PINC/month unlimited

---

### 3️⃣ ESCROW

**Flow:**
1. Client selects worker
2. Funds move to escrow
3. Worker does job
4. Client approves/rejects
5. Up to 3 revision attempts

---

### 4️⃣ DISPUTE RESOLUTION

**3-Attempt Rule:**
- Client can reject 3 times
- On 4th rejection → platform arbitrates

**Arbitration:**
- 3 random referees
- Cannot communicate with each other
- Submit result independently
- 2/3 consensus required

**Auto-Release:**
- If no dispute within timer (72h)
- Funds auto-release to worker

---

### 5️⃣ PAYOUT

**Fees:**
- Platform takes 9%
- Worker receives remaining

---

### 📁 FILE STRUCTURE
```
lib/
  features/
    jobs/
      post/
      bids/
      escrow/
      dispute/
      payout/
```

---

### 🔧 IMPLEMENTATION

**Services:**
1. `job_service.dart` - Job CRUD
2. `bid_service.dart` - Bid management
3. `escrow_service.dart` - Fund holding
4. `dispute_service.dart` - Arbitration
5. `payout_service.dart` - Payment

**UI:**
1. `jobs_screen.dart` - Browse jobs
2. `post_job_screen.dart`
3. `job_detail_screen.dart`
4. `my_jobs_screen.dart`

---

### ✅ COMPLETE CHECKLIST

- [ ] Post job (3% fee)
- [ ] Bid system
- [ ] Select worker
- [ ] Escrow management
- [ ] Work submission
- [ ] Approve/reject
- [ ] Dispute (3 referees)
- [ ] Payout (9%)

---

### 🎯 WHEN READY

**Instruction to paste to AI #7:**
```
Go to branch: ai7-jobs
Create your branch and implement:
- Post job (3% fee)
- Bid system
- Escrow
- Dispute resolution
- Payout (9%)
```

---

*AI #7: Jobs - Work without boundaries*